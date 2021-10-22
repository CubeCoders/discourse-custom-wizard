import { default as discourseComputed } from "discourse-common/utils/decorators";
import wizardSchema, {
  actionsRequiringAdditionalSubscription,
  actionSubscriptionLevel,
} from "discourse/plugins/discourse-custom-wizard/discourse/lib/wizard-schema";
import { empty, equal, or } from "@ember/object/computed";
import { notificationLevels, selectKitContent } from "../lib/wizard";
import { computed } from "@ember/object";
import UndoChanges from "../mixins/undo-changes";
import Component from "@ember/component";
import I18n from "I18n";

export default Component.extend(UndoChanges, {
  componentType: "action",
  classNameBindings: [":wizard-custom-action", "visible"],
  visible: computed("currentActionId", function () {
    return this.action.id === this.currentActionId;
  }),
  createTopic: equal("action.type", "create_topic"),
  updateProfile: equal("action.type", "update_profile"),
  watchCategories: equal("action.type", "watch_categories"),
  sendMessage: equal("action.type", "send_message"),
  openComposer: equal("action.type", "open_composer"),
  sendToApi: equal("action.type", "send_to_api"),
  addToGroup: equal("action.type", "add_to_group"),
  routeTo: equal("action.type", "route_to"),
  createCategory: equal("action.type", "create_category"),
  createGroup: equal("action.type", "create_group"),
  apiEmpty: empty("action.api"),
  groupPropertyTypes: selectKitContent(["id", "name"]),
  hasCustomFields: or(
    "basicTopicFields",
    "updateProfile",
    "createGroup",
    "createCategory"
  ),
  basicTopicFields: or("createTopic", "sendMessage", "openComposer"),
  publicTopicFields: or("createTopic", "openComposer"),
  showPostAdvanced: or("createTopic", "sendMessage"),
  availableNotificationLevels: notificationLevels.map((type) => {
    return {
      id: type,
      name: I18n.t(
        `admin.wizard.action.watch_categories.notification_level.${type}`
      ),
    };
  }),

  messageUrl: "https://thepavilion.io/t/2810",

  @discourseComputed("action.type")
  messageKey(type) {
    let key = "type";
    if (type) {
      key = "edit";
    }
    return key;
  },

  @discourseComputed("action.type")
  customFieldsContext(type) {
    return `action.${type}`;
  },

  @discourseComputed("wizard.steps")
  runAfterContent(steps) {
    let content = steps.map(function (step) {
      return {
        id: step.id,
        name: step.title || step.id,
      };
    });

    content.unshift({
      id: "wizard_completion",
      name: I18n.t("admin.wizard.action.run_after.wizard_completion"),
    });

    return content;
  },

  @discourseComputed("apis")
  availableApis(apis) {
    return apis.map((a) => {
      return {
        id: a.name,
        name: a.title,
      };
    });
  },

  @discourseComputed("apis", "action.api")
  availableEndpoints(apis, api) {
    if (!api) {
      return [];
    }
    return apis.find((a) => a.name === api).endpoints;
  },

  @discourseComputed("subscribed", "subscription")
  actionTypes(subscribed, subscription) {
    let unsubscribedActions = actionsRequiringAdditionalSubscription(
      subscription
    );
    return Object.keys(wizardSchema.action.types).reduce((result, type) => {
      let disabled = unsubscribedActions.includes(type);
      result.push({
        id: type,
        name: I18n.t(`admin.wizard.action.${type}.label`),
        subscription: actionSubscriptionLevel(type),
        disabled: disabled,
      });
      return result;
    }, []);
  },
});
