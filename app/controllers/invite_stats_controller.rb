# frozen_string_literal: true

class ::DiscourseInviteStats::InviteStatsController < ::ApplicationController
  requires_plugin DiscourseInviteStats::PLUGIN_NAME

  before_action :ensure_logged_in
  before_action :check_access
  skip_before_action :check_xhr, only: [:index]

  def index
    respond_to do |format|
      format.html { render "default/empty" }
      format.json { render json: cached_invite_tree }
    end
  end

  private

  def check_access
    allowed_group_names = SiteSetting.invite_stats_allowed_groups.split("|")

    return if current_user.staff?
    return if allowed_group_names.empty? # If no groups specified, allow all logged in users

    user_groups = current_user.groups.pluck(:name)
    has_access = (allowed_group_names & user_groups).any?

    if !has_access
      raise Discourse::InvalidAccess.new(
        "You need to be in one of these groups to view invite stats: #{allowed_group_names.join(', ')}",
        nil,
        custom_message: "invite_stats.access_denied"
      )
    end
  end

  def cached_invite_tree
    Rails.cache.fetch("invite_stats_v1", expires_in: 1.hour) do
      build_invite_tree
    end
  end

  def build_invite_tree
    # Query all users with their inviter information
    # Remove .not_suspended so we can see problematic users for moderation
    users_with_inviters = User
      .real
      .activated
      .limit(5000) # Safety limit for performance
      .select(
        "users.id",
        "users.username",
        "users.name",
        "users.uploaded_avatar_id",
        "users.created_at",
        "users.trust_level",
        "users.suspended_till",
        "users.suspended_at",
        "users.silenced_till",
        "user_stats.post_count",
        "user_stats.flags_agreed",
        "user_stats.flags_disagreed",
        "user_stats.flags_ignored",
        "invites.invited_by_id as inviter_id"
      )
      .joins("LEFT JOIN user_stats ON user_stats.user_id = users.id")
      .joins("LEFT JOIN invited_users ON invited_users.user_id = users.id")
      .joins("LEFT JOIN invites ON invites.id = invited_users.invite_id")
      .order("users.created_at ASC")

    # Build a hash for quick lookup with moderation metadata
    user_map = {}
    users_with_inviters.each do |user|
      flags_agreed = user.flags_agreed || 0
      flags_disagreed = user.flags_disagreed || 0
      flags_ignored = user.flags_ignored || 0
      total_flags = flags_agreed + flags_disagreed + flags_ignored

      user_map[user.id] = {
        id: user.id,
        username: user.username,
        name: user.name,
        avatar_template: User.avatar_template(user.username, user.uploaded_avatar_id),
        created_at: user.created_at,
        trust_level: user.trust_level,
        post_count: user.post_count,
        inviter_id: user.inviter_id,
        is_suspended: user.suspended_till.present?,
        is_silenced: user.silenced_till.present?,
        flags_received: total_flags,
        flags_agreed: flags_agreed,
        children: []
      }
    end

    # Build the tree structure
    roots = []
    user_map.each_value do |user_data|
      if user_data[:inviter_id] && user_map[user_data[:inviter_id]]
        # Add as child to inviter
        user_map[user_data[:inviter_id]][:children] << user_data
      else
        # Root user (no inviter or inviter not in system)
        roots << user_data
      end
    end

    # Add invite quality scores
    user_map.each_value do |user_data|
      user_data[:invite_quality_score] = calculate_invite_quality(user_data)
      user_data[:problematic_invites_count] = count_problematic_invites(user_data)
    end

    {
      roots: roots,
      total_users: user_map.size,
      problematic_inviters: find_problematic_inviters(user_map),
      summary: generate_summary(user_map)
    }
  end

  def calculate_invite_quality(user_data)
    children = user_data[:children]
    return 100.0 if children.empty?

    total = children.size
    problematic = count_problematic_invites(user_data)

    # Return percentage of good invites
    ((total - problematic).to_f / total * 100).round(2)
  end

  def count_problematic_invites(user_data)
    user_data[:children].count do |child|
      child[:is_suspended] ||
      child[:is_silenced] ||
      (child[:flags_agreed] && child[:flags_agreed] >= 3)
    end
  end

  def find_problematic_inviters(user_map)
    # Find users who invited 3+ problematic users OR have <70% success rate with 5+ invites
    user_map.values.select do |user|
      next false if user[:children].empty?

      problematic_count = count_problematic_invites(user)
      total_invites = user[:children].size
      quality_score = calculate_invite_quality(user)

      problematic_count >= 3 || (total_invites >= 5 && quality_score < 70)
    end.map do |user|
      {
        id: user[:id],
        username: user[:username],
        total_invites: user[:children].size,
        problematic_invites: count_problematic_invites(user),
        quality_score: user[:invite_quality_score]
      }
    end.sort_by { |u| -u[:problematic_invites] }
  end

  def generate_summary(user_map)
    users_with_invites = user_map.values.select { |u| u[:children].any? }
    total_invites = users_with_invites.sum { |u| u[:children].size }
    total_problematic = users_with_invites.sum { |u| count_problematic_invites(u) }

    {
      total_inviters: users_with_invites.size,
      total_invites: total_invites,
      total_problematic: total_problematic,
      overall_success_rate: total_invites > 0 ? ((total_invites - total_problematic).to_f / total_invites * 100).round(2) : 0
    }
  end
end
