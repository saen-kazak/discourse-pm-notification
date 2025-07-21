# name: discourse-pm-notification-control
# about: Admin UI to manage user notification levels in PMs
# version: 0.1
# authors: YourName
# required_version: 2.7.0

enabled_site_setting :pm_notification_control_enabled

register_asset "javascripts/discourse/components/pm-user-notification-control.js", :client_side
register_asset "javascripts/discourse/templates/components/pm-user-notification-control.hbs", :client_side

after_initialize do
  module ::PMNotificationControl
    class Engine < ::Rails::Engine
      engine_name "pm_notification_control"
      isolate_namespace PMNotificationControl
    end
  end

  require_dependency "application_controller"

  class PMNotificationControl::PmNotificationController < ::ApplicationController
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

  PMNotificationControl::Engine.routes.draw do
    put "/update" => "pm_notification#update"
  end

  Discourse::Application.routes.append do
    mount ::PMNotificationControl::Engine, at: "/pm_notification"
  end
end