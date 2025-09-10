require 'test_plugin_helper'

class SettingsProtectionTest < ActiveSupport::TestCase
  setup do
    @rh_cloud_settings = [
      'allow_auto_inventory_upload',
      'allow_auto_insights_sync',
      'allow_auto_insights_mismatch_delete',
      'obfuscate_inventory_hostnames',
      'obfuscate_inventory_ips',
      'exclude_installed_packages',
      'include_parameter_tags',
      'rhc_instance_id',
      'insights_minimal_data_collection'
    ]
  end

  test 'controllers handle missing settings gracefully' do
    @rh_cloud_settings.each do |setting_name|
      Foreman.settings.stubs(:find).with(setting_name).returns(nil)
      
      # Test uploads_settings_controller index
      controller = ForemanInventoryUpload::UploadsSettingsController.new
      result = controller.send(:index)
      
      # Verify that the controller doesn't crash and returns default values
      assert_not_nil result
      
      Foreman.settings.unstub(:find)
    end
  end

  test 'uploads_settings_controller index returns false for missing settings' do
    # Mock all rh_cloud settings as missing
    @rh_cloud_settings.each do |setting_name|
      Foreman.settings.stubs(:find).with(setting_name).returns(nil)
    end
    
    # Mock non-rh_cloud setting as present
    Foreman.settings.stubs(:find).with('subscription_connection_enabled').returns(true)
    Setting.stubs(:[]).with(:subscription_connection_enabled).returns(true)
    
    controller = ForemanInventoryUpload::UploadsSettingsController.new
    controller.stubs(:last_successful_inventory_sync_task).returns(nil)
    ForemanInventoryUpload::UploadsSettingsController.stubs(:cloud_connector_status).returns(nil)
    
    # Capture the response
    controller.stubs(:render) do |args|
      json_data = args[:json]
      
      # Verify that rh_cloud settings default to false when missing
      assert_equal false, json_data[:insightsMinimalDataCollection]
      assert_equal false, json_data[:autoUploadEnabled]
      assert_equal false, json_data[:hostObfuscationEnabled]
      assert_equal false, json_data[:ipsObfuscationEnabled]
      assert_equal false, json_data[:excludePackagesEnabled]
      assert_equal false, json_data[:allowAutoInsightsMismatchDelete]
      
      # Non-rh_cloud setting should work normally
      assert_equal true, json_data[:subscriptionConnectionEnabled]
    end
    
    controller.send(:index)
    
    @rh_cloud_settings.each { |setting| Foreman.settings.unstub(:find) }
  end

  test 'uploads_settings_controller set_advanced_setting ignores missing settings' do
    setting_name = 'allow_auto_inventory_upload'
    Foreman.settings.stubs(:find).with(setting_name).returns(nil)
    
    controller = ForemanInventoryUpload::UploadsSettingsController.new
    controller.stubs(:params).returns(
      ActionController::Parameters.new(setting: setting_name, value: 'true')
    )
    controller.stubs(:index)
    
    # Setting should not be called when the setting is missing
    Setting.expects(:[]=).never
    
    controller.send(:set_advanced_setting)
    
    Foreman.settings.unstub(:find)
  end

  test 'insights_settings_controller handles missing settings' do
    setting_name = 'allow_auto_insights_sync'
    Foreman.settings.stubs(:find).with(setting_name).returns(nil)
    
    controller = InsightsCloud::SettingsController.new
    controller.stubs(:settings_params).returns(true)
    
    # Mock render_setting method call
    controller.stubs(:render_setting) do |node_name, setting|
      assert_equal :insightsSyncEnabled, node_name
      assert_equal :allow_auto_insights_sync, setting
    end
    
    # Setting should not be called when the setting is missing
    Setting.expects(:[]=).never
    
    controller.send(:update)
    
    Foreman.settings.unstub(:find)
  end

  test 'render_setting returns false for missing settings' do
    setting_name = 'allow_auto_insights_sync'
    Foreman.settings.stubs(:find).with(setting_name.to_s).returns(nil)
    
    controller = InsightsCloud::SettingsController.new
    
    controller.stubs(:render) do |args|
      json_data = args[:json]
      assert_equal false, json_data[:insightsSyncEnabled]
    end
    
    controller.send(:render_setting, :insightsSyncEnabled, setting_name.to_sym)
    
    Foreman.settings.unstub(:find)
  end

  test 'cloud_presence handles missing rhc_instance_id setting' do
    organization = FactoryBot.create(:organization)
    logger = mock('logger')
    
    Foreman.settings.stubs(:find).with('rhc_instance_id').returns(nil)
    
    cloud_presence = ForemanRhCloud::CloudPresence.new(organization, logger)
    
    exception = assert_raises(Foreman::Exception) do
      cloud_presence.send(:register_rhc_instance)
    end
    
    assert_match(/rhc_instance_id is empty/, exception.message)
    
    Foreman.settings.unstub(:find)
  end

  test 'generators handle missing settings gracefully' do
    host = FactoryBot.create(:host, :managed)
    
    # Test tags generator with missing include_parameter_tags
    Foreman.settings.stubs(:find).with('include_parameter_tags').returns(nil)
    tags_generator = ForemanInventoryUpload::Generators::Tags.new(host)
    parameters = tags_generator.generate_parameters
    assert_equal [], parameters
    Foreman.settings.unstub(:find)
    
    # Test fact helpers with missing obfuscation settings
    Foreman.settings.stubs(:find).with('obfuscate_inventory_hostnames').returns(nil)
    fact_helpers = Class.new { include ForemanInventoryUpload::Generators::FactHelpers }.new
    result = fact_helpers.send(:obfuscate_hostname?, host)
    assert_equal false, result
    Foreman.settings.unstub(:find)
    
    Foreman.settings.stubs(:find).with('obfuscate_inventory_ips').returns(nil)
    result = fact_helpers.send(:obfuscate_ips?, host)
    assert_equal false, result
    Foreman.settings.unstub(:find)
  end

  test 'scheduled sync jobs handle missing settings' do
    # Test inventory scheduled sync
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(nil)
    job = InventorySync::Async::InventoryScheduledSync.new
    job.stubs(:logger).returns(mock('logger', debug: nil))
    
    # Should return early when setting is missing
    job.send(:plan)
    # No assertion needed - just ensuring no exception is raised
    
    Foreman.settings.unstub(:find)
    
    # Test insights scheduled sync
    Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(nil)
    insights_job = InsightsCloud::Async::InsightsScheduledSync.new
    insights_job.stubs(:logger).returns(mock('logger', debug: nil))
    
    # Should return early when setting is missing
    insights_job.send(:plan)
    # No assertion needed - just ensuring no exception is raised
    
    Foreman.settings.unstub(:find)
  end
end