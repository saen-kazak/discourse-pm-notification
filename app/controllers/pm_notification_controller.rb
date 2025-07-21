module PMNotificationControl
  class PmNotificationController < ::ApplicationController
    before_action :ensure_logged_in
    before_action :ensure_admin

    def update
      user = User.find_by_username(params[:username])
      topic = Topic.find(params[:topic_id])
      notification_level = params[:notification_level].to_i

      if user && topic
        TopicUser.change(user.id, topic.id, notification_level: notification_level)
        render json: success_json
      else
        render json: failed_json, status: 422
      end
    end
  end
end