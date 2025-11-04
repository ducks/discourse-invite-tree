# frozen_string_literal: true

require "rails_helper"

describe DiscourseInviteStats::InviteStatsController do
  fab!(:user) { Fabricate(:user) }
  fab!(:admin) { Fabricate(:admin) }
  fab!(:group) { Fabricate(:group) }

  before do
    SiteSetting.invite_stats_enabled = true
  end

  describe "#index" do
    context "when not logged in" do
      it "returns 403" do
        get "/invite-stats.json"
        expect(response.status).to eq(403)
      end
    end

    context "when logged in as regular user" do
      before do
        sign_in(user)
      end

      context "with no group restrictions" do
        before do
          SiteSetting.invite_stats_allowed_groups = ""
        end

        it "allows access" do
          get "/invite-stats.json"
          expect(response.status).to eq(200)
          json = JSON.parse(response.body)
          expect(json).to have_key("roots")
          expect(json).to have_key("summary")
          expect(json).to have_key("problematic_inviters")
        end
      end

      context "with group restrictions" do
        before do
          SiteSetting.invite_stats_allowed_groups = "#{group.name}"
        end

        it "denies access when user not in group" do
          get "/invite-stats.json"
          expect(response.status).to eq(403)
        end

        it "allows access when user in group" do
          group.add(user)
          get "/invite-stats.json"
          expect(response.status).to eq(200)
        end
      end
    end

    context "when logged in as admin" do
      before do
        sign_in(admin)
        SiteSetting.invite_stats_allowed_groups = "some_other_group"
      end

      it "allows access regardless of group restrictions" do
        get "/invite-stats.json"
        expect(response.status).to eq(200)
      end
    end

    context "response structure" do
      before do
        sign_in(admin)
      end

      it "includes all expected fields" do
        get "/invite-stats.json"
        json = JSON.parse(response.body)

        expect(json).to have_key("roots")
        expect(json).to have_key("total_users")
        expect(json).to have_key("problematic_inviters")
        expect(json).to have_key("summary")

        summary = json["summary"]
        expect(summary).to have_key("total_inviters")
        expect(summary).to have_key("total_invites")
        expect(summary).to have_key("total_problematic")
        expect(summary).to have_key("overall_success_rate")
      end
    end
  end
end
