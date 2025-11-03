# frozen_string_literal: true

# name: discourse-invite-tree
# about: Public invite tree visualization with invite-only registration mode
# version: 0.1.0
# authors: Jake Goldsborough
# url: https://github.com/ducks/discourse-invite-tree

enabled_site_setting :invite_tree_enabled

register_asset "stylesheets/invite-tree.scss"

after_initialize do
  module ::DiscourseInviteTree
    PLUGIN_NAME = "discourse-invite-tree"
  end

  require_relative "app/controllers/invite_tree_controller"
  require_relative "app/serializers/invite_tree_serializer"

  Discourse::Application.routes.append do
    get "/invite-tree" => "discourse_invite_tree/invite_tree#index"
    get "/invite-tree.json" => "discourse_invite_tree/invite_tree#tree_data"
  end
end
