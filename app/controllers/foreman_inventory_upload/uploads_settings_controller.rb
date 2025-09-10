module ForemanInventoryUpload
  class UploadsSettingsController < ::ApplicationController
    def index
      render json: {
        insightsMinimalDataCollection: Foreman.settings.find('insights_minimal_data_collection') ? Setting[:insights_minimal_data_collection] : false,
        autoUploadEnabled: Foreman.settings.find('allow_auto_inventory_upload') ? Setting[:allow_auto_inventory_upload] : false,
        subscriptionConnectionEnabled: Setting[:subscription_connection_enabled],
        hostObfuscationEnabled: Foreman.settings.find('obfuscate_inventory_hostnames') ? Setting[:obfuscate_inventory_hostnames] : false,
        ipsObfuscationEnabled: Foreman.settings.find('obfuscate_inventory_ips') ? Setting[:obfuscate_inventory_ips] : false,
        excludePackagesEnabled: Foreman.settings.find('exclude_installed_packages') ? Setting[:exclude_installed_packages] : false,
        allowAutoInsightsMismatchDelete: Foreman.settings.find('allow_auto_insights_mismatch_delete') ? Setting[:allow_auto_insights_mismatch_delete] : false,
        CloudConnectorStatus: ForemanInventoryUpload::UploadsSettingsController.cloud_connector_status,
        lastSyncTask: last_successful_inventory_sync_task,
      }, status: :ok
    end

    def set_advanced_setting
      setting_name = params.require(:setting)
      if Foreman.settings.find(setting_name)
        Setting[setting_name] = ActiveModel::Type::Boolean.new.cast(params.require(:value))
      end
      index
    end

    def self.cloud_connector_status
      cloud_connector = ForemanRhCloud::CloudConnector.new
      job = cloud_connector&.latest_job
      return nil unless job
      { id: job.id, task: ForemanTasks::Task.where(:id => job.task_id).first }
    end

    def last_successful_inventory_sync_task
      task = ForemanTasks::Task.where(label: 'InventorySync::Async::InventoryFullSync', result: 'success')
                        .reorder('ended_at desc').first
      return nil unless task
      { output: task.output, endedAt: task.ended_at }
    end
  end
end
