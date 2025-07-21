import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { tracked } from "@glimmer/tracking";

export default class PmUserNotificationControl extends Component {
  @service currentUser;

  @tracked loading = false;

  get isPm() {
    return this.args.topic.details.allowed_users?.length > 0;
  }

  get canEdit() {
    return this.currentUser?.admin && this.isPm;
  }

  get users() {
    return this.args.topic.details.allowed_users.map((user) => {
      return {
        username: user.username,
        name: user.name,
        notification_level: this.args.topic.details.participants.find(p => p.username === user.username)?.notification_level
      };
    });
  }

  @action
  async changeNotificationLevel(username, level) {
    this.loading = true;
    try {
      await ajax("/pm_notification/update", {
        type: "PUT",
        data: {
          username,
          topic_id: this.args.topic.id,
          notification_level: level,
        },
      });
    } finally {
      this.loading = false;
    }
  }
}