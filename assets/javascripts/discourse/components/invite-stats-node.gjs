import Component from "@glimmer/component";
import { service } from "@ember/service";
import { gt } from "truth-helpers";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import icon from "discourse-common/helpers/d-icon";
import { htmlSafe } from "@ember/template";

export default class InviteStatsNode extends Component {
  @service siteSettings;

  get hasChildren() {
    return this.args.user.children && this.args.user.children.length > 0;
  }

  get childCount() {
    return this.args.user.children?.length || 0;
  }

  get treePrefix() {
    // Create tree-style prefix like Lobsters
    if (this.args.depth === 0) {
      return htmlSafe("");
    }

    let prefix = "";
    for (let i = 0; i < this.args.depth - 1; i++) {
      prefix += "│\u00A0\u00A0"; // vertical line + 2 spaces
    }
    // Use └─ for last child, ├─ for others
    prefix += this.args.isLast ? "└─\u00A0" : "├─\u00A0";
    return htmlSafe(prefix);
  }

  get nextDepth() {
    return (this.args.depth || 0) + 1;
  }

  isLastChild = (index) => {
    return index === this.args.user.children.length - 1;
  };

  <template>
    <div class="invite-stats-node">
      <div class="invite-stats-node-content">
        <span class="tree-prefix">{{this.treePrefix}}</span>
        <a href="/u/{{@user.username}}" class="username">{{@user.username}}</a>
        <span class="user-meta">
          ({{formatDate @user.created_at format="tiny" noTitle="true"}})
          {{#if this.hasChildren}}
            <span class="invite-count">[{{this.childCount}}]</span>
          {{/if}}
          {{#if @user.is_suspended}}
            <span class="moderation-indicator suspended" title="Suspended">🚫</span>
          {{/if}}
          {{#if @user.is_silenced}}
            <span class="moderation-indicator silenced" title="Silenced">🔇</span>
          {{/if}}
          {{#if @user.flags_agreed}}
            {{#if (gt @user.flags_agreed 0)}}
              <span class="moderation-indicator flags" title="{{@user.flags_agreed}} agreed flags">⚠️{{@user.flags_agreed}}</span>
            {{/if}}
          {{/if}}
          {{#if @user.problematic_invites_count}}
            {{#if (gt @user.problematic_invites_count 0)}}
              <span class="moderation-indicator problematic-invites" title="{{@user.problematic_invites_count}} problematic invites">[{{@user.problematic_invites_count}} bad]</span>
            {{/if}}
          {{/if}}
          {{#if @user.invite_quality_score}}
            {{#if this.hasChildren}}
              <span class="quality-score" title="Invite quality score">{{@user.invite_quality_score}}%</span>
            {{/if}}
          {{/if}}
        </span>
      </div>

      {{#if this.hasChildren}}
        {{#each @user.children as |child index|}}
          <InviteStatsNode
            @user={{child}}
            @depth={{this.nextDepth}}
            @isLast={{this.isLastChild index}} />
        {{/each}}
      {{/if}}
    </div>
  </template>
}
