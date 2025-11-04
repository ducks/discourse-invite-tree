import DiscourseRoute from "discourse/routes/discourse";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

export default class InviteStatsRoute extends DiscourseRoute {
  @service router;
  @service siteSettings;

  beforeModel() {
    if (!this.siteSettings.invite_stats_enabled) {
      this.router.transitionTo("discovery.latest");
    }
  }

  model() {
    return ajax("/invite-stats.json", {
      type: "GET",
      dataType: "json",
    });
  }

  titleToken() {
    return i18n("invite_stats.title");
  }
}
