# frozen_string_literal: true

class ::DiscourseInviteTree::InviteTreeController < ::ApplicationController
  requires_plugin DiscourseInviteTree::PLUGIN_NAME

  skip_before_action :check_xhr, only: [:index]

  def index
    # Render the Ember route or return JSON data
    respond_to do |format|
      format.html { render "default/empty" }
      format.json { render json: build_invite_tree }
    end
  end

  def tree_data
    # Build the invite tree structure
    tree = build_invite_tree

    render json: tree
  end

  private

  def build_invite_tree
    # Query all users with their inviter information
    users_with_inviters = User
      .real
      .activated
      .not_suspended
      .select(
        "users.id",
        "users.username",
        "users.name",
        "users.uploaded_avatar_id",
        "users.created_at",
        "users.trust_level",
        "user_stats.post_count",
        "invites.invited_by_id as inviter_id"
      )
      .joins("LEFT JOIN user_stats ON user_stats.user_id = users.id")
      .joins("LEFT JOIN invited_users ON invited_users.user_id = users.id")
      .joins("LEFT JOIN invites ON invites.id = invited_users.invite_id")
      .order("users.created_at ASC")

    # Build a hash for quick lookup
    user_map = {}
    users_with_inviters.each do |user|
      user_map[user.id] = {
        id: user.id,
        username: user.username,
        name: user.name,
        avatar_template: User.avatar_template(user.username, user.uploaded_avatar_id),
        created_at: user.created_at,
        trust_level: user.trust_level,
        post_count: user.post_count,
        inviter_id: user.inviter_id,
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

    {
      roots: roots,
      total_users: user_map.size
    }
  end
end
