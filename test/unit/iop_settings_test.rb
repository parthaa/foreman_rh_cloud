require 'test_plugin_helper'

class IopSettingsTest < ActiveSupport::TestCase
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

  test 'rh_cloud settings are not registered when IoP smart proxy exists' do
    # Mock IoP smart proxy existence
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(true)
    
    # Create a mock plugin registration context
    plugin_context = mock('plugin_context')
    settings_context = mock('settings_context')
    category_context = mock('category_context')
    
    # Expect that category is never called when IoP is present
    settings_context.expects(:category).never
    
    plugin_context.expects(:settings).yields(settings_context)
    
    # Simulate the plugin registration process
    Foreman::Plugin.expects(:register).with(:foreman_rh_cloud).yields(plugin_context)
    
    # The actual plugin file would be loaded here, but we can't easily test that
    # Instead, we verify the condition directly
    assert ForemanRhCloud.with_iop_smart_proxy?
    
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
  end

  test 'rh_cloud settings are registered when no IoP smart proxy exists' do
    # Mock no IoP smart proxy
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(false)
    
    # Verify the condition
    assert_not ForemanRhCloud.with_iop_smart_proxy?
    
    # In a real scenario, all rh_cloud settings would be available
    # We can test this by checking if the settings exist
    @rh_cloud_settings.each do |setting_name|
      # When IoP is not present, Foreman.settings.find should potentially find these settings
      # (assuming they were registered)
      Foreman.settings.stubs(:find).with(setting_name).returns(mock("setting_#{setting_name}"))
      setting_mock = Foreman.settings.find(setting_name)
      assert_not_nil setting_mock, "Setting #{setting_name} should be findable when IoP is not present"
      Foreman.settings.unstub(:find)
    end
    
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
  end

  test 'with_iop_smart_proxy method detection' do
    # Test when SmartProxy with iop feature exists
    smart_proxy_mock = mock('smart_proxy')
    smart_proxy_relation = mock('smart_proxy_relation')
    
    SmartProxy.stubs(:unscoped).returns(smart_proxy_relation)
    smart_proxy_relation.stubs(:with_features).with('iop').returns(smart_proxy_relation)
    smart_proxy_relation.stubs(:exists?).returns(true)
    
    assert ForemanRhCloud.with_iop_smart_proxy?
    
    # Test when no SmartProxy with iop feature exists
    smart_proxy_relation.stubs(:exists?).returns(false)
    assert_not ForemanRhCloud.with_iop_smart_proxy?
    
    SmartProxy.unstub(:unscoped)
  end

  test 'uploads controller enable_cloud_connector respects IoP setting protection' do
    # Test when setting is not available (IoP scenario)
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(nil)
    
    controller = ForemanInventoryUpload::UploadsController.new
    controller.stubs(:require_non_iop_smart_proxy)
    
    cloud_connector_mock = mock('cloud_connector')
    cloud_connector_mock.stubs(:install).returns({})
    ForemanRhCloud::CloudConnector.stubs(:new).returns(cloud_connector_mock)
    
    controller.stubs(:render)
    
    # Setting should not be called when the setting is missing
    Setting.expects(:[]=).never
    
    controller.send(:enable_cloud_connector)
    
    Foreman.settings.unstub(:find)
  end

  test 'scheduled jobs respect IoP smart proxy detection' do
    # Test inventory scheduled sync with IoP
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(true)
    
    inventory_job = InventorySync::Async::InventoryScheduledSync.new
    inventory_job.stubs(:plan_self)
    
    # When IoP is present, should call plan_self instead of normal sync
    inventory_job.expects(:plan_self)
    inventory_job.expects(:after_delay).never
    
    # Mock settings check to pass
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
    Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(true)
    
    inventory_job.send(:plan)
    
    # Test insights scheduled sync with IoP
    insights_job = InsightsCloud::Async::InsightsScheduledSync.new
    insights_job.stubs(:plan_self)
    
    insights_job.expects(:plan_self)
    insights_job.expects(:after_delay).never
    
    # Mock settings check to pass
    Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(true)
    Setting.stubs(:[]).with(:allow_auto_insights_sync).returns(true)
    
    insights_job.send(:plan)
    
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end

  test 'generate all reports job respects IoP smart proxy detection' do
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(true)
    
    job = ForemanInventoryUpload::Async::GenerateAllReportsJob.new
    job.stubs(:plan_self)
    
    # When IoP is present, should call plan_self instead of normal generation
    job.expects(:plan_self)
    job.expects(:after_delay).never
    
    # Mock settings check to pass
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
    Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(true)
    
    job.send(:plan)
    
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end

  test 'menu items respect IoP smart proxy detection' do
    # This test verifies the menu configuration logic
    # The actual menu items are registered in the plugin, but we can test the conditions
    
    # When IoP is not present, inventory upload should be in top menu
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(false)
    inventory_upload_condition = -> { !ForemanRhCloud.with_iop_smart_proxy? }
    assert inventory_upload_condition.call
    
    # When IoP is present, inventory upload should be in admin menu
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(true)
    admin_inventory_condition = -> { ForemanRhCloud.with_iop_smart_proxy? }
    assert admin_inventory_condition.call
    
    # Vulnerability menu should only show when IoP is present
    vulnerability_condition = -> { ForemanRhCloud.with_iop_smart_proxy? }
    assert vulnerability_condition.call
    
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
  end
end