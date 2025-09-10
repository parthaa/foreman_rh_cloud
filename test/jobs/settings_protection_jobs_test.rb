require 'test_plugin_helper'

class SettingsProtectionJobsTest < ActiveSupport::TestCase
  test 'inventory scheduled sync handles missing allow_auto_inventory_upload setting' do
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(nil)
    
    job = InventorySync::Async::InventoryScheduledSync.new
    logger_mock = mock('logger')
    logger_mock.expects(:debug).with(includes('allow_auto_inventory_upload'))
    job.stubs(:logger).returns(logger_mock)
    
    # Should return early without planning any actions
    job.expects(:after_delay).never
    job.expects(:plan_self).never
    
    result = job.send(:plan)
    
    # Should return nil/early when setting is missing
    assert_nil result
    
    Foreman.settings.unstub(:find)
  end

  test 'inventory scheduled sync works when setting is present and true (non-IoP)' do
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
    Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(true)
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(false)
    
    job = InventorySync::Async::InventoryScheduledSync.new
    
    # Should call after_delay for non-IoP scenario
    job.expects(:after_delay).once
    job.expects(:plan_self).never
    
    job.send(:plan)
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
  end

  test 'inventory scheduled sync works when setting is present and true (IoP)' do
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
    Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(true)
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(true)
    
    job = InventorySync::Async::InventoryScheduledSync.new
    
    # Should call plan_self for IoP scenario
    job.expects(:plan_self).once
    job.expects(:after_delay).never
    
    job.send(:plan)
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
  end

  test 'inventory scheduled sync handles missing allow_auto_insights_mismatch_delete setting' do
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
    Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(true)
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(false)
    
    # Mock the mismatch delete setting as missing
    Foreman.settings.stubs(:find).with('allow_auto_insights_mismatch_delete').returns(nil)
    
    job = InventorySync::Async::InventoryScheduledSync.new
    
    # Mock the organization and plan methods
    Organization.stubs(:unscoped).returns(mock('org_relation', each: []))
    job.stubs(:plan_org_sync)
    job.stubs(:plan_remove_insights_hosts).never # Should not be called when setting is missing
    
    # Mock the after_delay block execution
    job.stubs(:after_delay).yields
    job.stubs(:concurrence).yields
    job.stubs(:sequence).yields
    
    job.send(:plan)
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
    Organization.unstub(:unscoped)
  end

  test 'insights scheduled sync handles missing allow_auto_insights_sync setting' do
    Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(nil)
    
    job = InsightsCloud::Async::InsightsScheduledSync.new
    logger_mock = mock('logger')
    logger_mock.expects(:debug).with(includes('allow_auto_insights_sync'))
    job.stubs(:logger).returns(logger_mock)
    
    # Should return early without planning any actions
    job.expects(:after_delay).never
    job.expects(:plan_self).never
    
    result = job.send(:plan)
    
    # Should return nil/early when setting is missing
    assert_nil result
    
    Foreman.settings.unstub(:find)
  end

  test 'insights scheduled sync works when setting is present and true (non-IoP)' do
    Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(true)
    Setting.stubs(:[]).with(:allow_auto_insights_sync).returns(true)
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(false)
    
    job = InsightsCloud::Async::InsightsScheduledSync.new
    
    # Should call after_delay for non-IoP scenario
    job.expects(:after_delay).once
    job.expects(:plan_self).never
    
    job.send(:plan)
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
  end

  test 'insights scheduled sync works when setting is present and true (IoP)' do
    Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(true)
    Setting.stubs(:[]).with(:allow_auto_insights_sync).returns(true)
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(true)
    
    job = InsightsCloud::Async::InsightsScheduledSync.new
    
    # Should call plan_self for IoP scenario
    job.expects(:plan_self).once
    job.expects(:after_delay).never
    
    job.send(:plan)
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
  end

  test 'generate all reports job handles missing allow_auto_inventory_upload setting' do
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(nil)
    
    job = ForemanInventoryUpload::Async::GenerateAllReportsJob.new
    logger_mock = mock('logger')
    logger_mock.expects(:debug).with(includes('allow_auto_inventory_upload'))
    job.stubs(:logger).returns(logger_mock)
    
    # Should return early without planning any actions
    job.expects(:after_delay).never
    job.expects(:plan_self).never
    
    result = job.send(:plan)
    
    # Should return nil/early when setting is missing
    assert_nil result
    
    Foreman.settings.unstub(:find)
  end

  test 'generate all reports job works when setting is present and true (non-IoP)' do
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
    Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(true)
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(false)
    
    job = ForemanInventoryUpload::Async::GenerateAllReportsJob.new
    
    # Mock organizations
    organizations = []
    Organization.stubs(:unscoped).returns(mock('org_relation', all: organizations))
    
    # Should call after_delay for non-IoP scenario
    job.expects(:after_delay).once
    job.expects(:plan_self).never
    
    job.send(:plan)
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
    Organization.unstub(:unscoped)
  end

  test 'generate all reports job works when setting is present and true (IoP)' do
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
    Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(true)
    ForemanRhCloud.stubs(:with_iop_smart_proxy?).returns(true)
    
    job = ForemanInventoryUpload::Async::GenerateAllReportsJob.new
    
    # Should call plan_self for IoP scenario
    job.expects(:plan_self).once
    job.expects(:after_delay).never
    
    job.send(:plan)
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
    ForemanRhCloud.unstub(:with_iop_smart_proxy?)
  end

  test 'job returns early when setting is false even if present' do
    Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
    Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(false)
    
    job = InventorySync::Async::InventoryScheduledSync.new
    logger_mock = mock('logger')
    logger_mock.expects(:debug).with(includes('allow_auto_inventory_upload'))
    job.stubs(:logger).returns(logger_mock)
    
    # Should return early when setting is false
    job.expects(:after_delay).never
    job.expects(:plan_self).never
    
    result = job.send(:plan)
    
    # Should return nil/early when setting is false
    assert_nil result
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end
end