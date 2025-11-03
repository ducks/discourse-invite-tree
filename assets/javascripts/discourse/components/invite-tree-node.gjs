import Component from "@glimmer/component";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import icon from "discourse-common/helpers/d-icon";
import { htmlSafe } from "@ember/template";

export default class InviteTreeNode extends Component {
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
    prefix += "├─\u00A0"; // branch + horizontal line + space
    return htmlSafe(prefix);
  }

  get nextDepth() {
    return (this.args.depth || 0) + 1;
  }

  <template>
    <div class="invite-tree-node">
      <div class="invite-tree-node-content">
        <span class="tree-prefix">{{this.treePrefix}}</span>
        <a href="/u/{{@user.username}}" class="username">{{@user.username}}</a>
        <span class="user-meta">
          ({{formatDate @user.created_at format="tiny" noTitle="true"}})
          {{#if this.hasChildren}}
            <span class="invite-count">[{{this.childCount}}]</span>
          {{/if}}
        </span>
      </div>

      {{#if this.hasChildren}}
        {{#each @user.children as |child|}}
          <InviteTreeNode @user={{child}} @depth={{this.nextDepth}} />
        {{/each}}
      {{/if}}
    </div>
  </template>
}
