# frozen_string_literal: true

class ::DiscourseInviteStats::InviteStatsSerializer < ApplicationSerializer
  attributes :id, :username, :name, :avatar_template, :created_at, :trust_level, :post_count, :children

  def children
    object[:children] || []
  end
end
