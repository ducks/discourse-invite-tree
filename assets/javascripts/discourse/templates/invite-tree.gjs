import InviteTreeNode from "../components/invite-tree-node";
import { i18n } from "discourse-i18n";

<template>
  <div class="invite-tree-container">
    <div class="invite-tree-header">
      <h1>{{i18n "invite_tree.title"}}</h1>
      <p class="invite-tree-description">{{i18n "invite_tree.description"}}</p>
      {{#if @model.total_users}}
        <p class="invite-tree-stats">
          {{i18n "invite_tree.total_members" count=@model.total_users}}
        </p>
      {{/if}}
    </div>

    <div class="invite-tree-content">
      {{#if @model.roots}}
        <div class="invite-tree-roots">
          {{#each @model.roots as |user|}}
            <InviteTreeNode @user={{user}} @depth={{0}} />
          {{/each}}
        </div>
      {{else}}
        <div class="invite-tree-empty">
          {{i18n "invite_tree.no_invites"}}
        </div>
      {{/if}}
    </div>
  </div>
</template>
