# frozen_string_literal: true

# name: discourse-invite-stats
# about: Invite statistics and accountability tracking with tree visualization
# version: 0.2.0
# authors: Jake Goldsborough
# url: https://github.com/ducks/discourse-invite-stats

enabled_site_setting :invite_stats_enabled

register_asset "stylesheets/invite-stats.scss"

after_initialize do
  module ::DiscourseInviteStats
    PLUGIN_NAME = "discourse-invite-stats"
  end

  require_relative "app/controllers/invite_stats_controller"
  require_relative "app/serializers/invite_stats_serializer"

  Discourse::Application.routes.append do
    get "/invite-stats" => "discourse_invite_stats/invite_stats#index"
    get "/invite-stats.json" => "discourse_invite_stats/invite_stats#index"
  end
end
