require 'test_plugin_helper'

class SettingsProtectionControllerTest < ActionController::TestCase
  setup do
    @organization = FactoryBot.create(:organization)
    @user = FactoryBot.create(:user, :with_mail)
    @user.organizations << @organization
    
    # Setup roles and permissions
    role = FactoryBot.create(:role, :name => 'ForemanRhCloud')
    permission = FactoryBot.create(:permission, :name => 'view_foreman_rh_cloud')
    FactoryBot.create(:filter, :role => role, :permissions => [permission])
    @user.roles << role
    
    as_user(@user) do
      @request.session[:user] = @user.id
      @request.session[:organization_id] = @organization.id
    end
  end

  class UploadsSettingsProtectionTest < SettingsProtectionControllerTest
    tests ForemanInventoryUpload::UploadsSettingsController

    test 'index handles missing rh_cloud settings gracefully' do
      # Mock all rh_cloud settings as missing
      rh_cloud_settings = [
        'insights_minimal_data_collection',
        'allow_auto_inventory_upload',
        'obfuscate_inventory_hostnames',
        'obfuscate_inventory_ips',
        'exclude_installed_packages',
        'allow_auto_insights_mismatch_delete'
      ]
      
      rh_cloud_settings.each do |setting|
        Foreman.settings.stubs(:find).with(setting).returns(nil)
      end
      
      # Mock non-rh_cloud setting as present
      Setting.stubs(:[]).with(:subscription_connection_enabled).returns(true)
      
      get :index, session: set_session_user
      
      assert_response :success
      
      response_data = JSON.parse(response.body)
      
      # Verify that missing rh_cloud settings default to false
      assert_equal false, response_data['insightsMinimalDataCollection']
      assert_equal false, response_data['autoUploadEnabled']
      assert_equal false, response_data['hostObfuscationEnabled']
      assert_equal false, response_data['ipsObfuscationEnabled']
      assert_equal false, response_data['excludePackagesEnabled']
      assert_equal false, response_data['allowAutoInsightsMismatchDelete']
      
      # Non-rh_cloud setting should work normally
      assert_equal true, response_data['subscriptionConnectionEnabled']
      
      rh_cloud_settings.each { |setting| Foreman.settings.unstub(:find) }
      Setting.unstub(:[])
    end

    test 'index returns actual values when rh_cloud settings are present' do
      # Mock all rh_cloud settings as present
      Foreman.settings.stubs(:find).with('insights_minimal_data_collection').returns(true)
      Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
      Foreman.settings.stubs(:find).with('obfuscate_inventory_hostnames').returns(true)
      Foreman.settings.stubs(:find).with('obfuscate_inventory_ips').returns(true)
      Foreman.settings.stubs(:find).with('exclude_installed_packages').returns(true)
      Foreman.settings.stubs(:find).with('allow_auto_insights_mismatch_delete').returns(true)
      
      # Mock the actual setting values
      Setting.stubs(:[]).with(:insights_minimal_data_collection).returns(true)
      Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(false)
      Setting.stubs(:[]).with(:obfuscate_inventory_hostnames).returns(true)
      Setting.stubs(:[]).with(:obfuscate_inventory_ips).returns(false)
      Setting.stubs(:[]).with(:exclude_installed_packages).returns(true)
      Setting.stubs(:[]).with(:allow_auto_insights_mismatch_delete).returns(false)
      Setting.stubs(:[]).with(:subscription_connection_enabled).returns(true)
      
      get :index, session: set_session_user
      
      assert_response :success
      
      response_data = JSON.parse(response.body)
      
      # Verify that present settings return their actual values
      assert_equal true, response_data['insightsMinimalDataCollection']
      assert_equal false, response_data['autoUploadEnabled']
      assert_equal true, response_data['hostObfuscationEnabled']
      assert_equal false, response_data['ipsObfuscationEnabled']
      assert_equal true, response_data['excludePackagesEnabled']
      assert_equal false, response_data['allowAutoInsightsMismatchDelete']
      
      Foreman.settings.unstub(:find)
      Setting.unstub(:[])
    end

    test 'set_advanced_setting ignores missing settings' do
      setting_name = 'allow_auto_inventory_upload'
      Foreman.settings.stubs(:find).with(setting_name).returns(nil)
      
      # Mock non-rh_cloud setting for the response
      Setting.stubs(:[]).with(:subscription_connection_enabled).returns(true)
      
      post :set_advanced_setting, 
           params: { setting: setting_name, value: 'true' }, 
           session: set_session_user
      
      assert_response :success
      
      # The missing setting should not have been set
      # (This is implicitly tested by not stubbing Setting[]= and ensuring no error occurs)
      
      Foreman.settings.unstub(:find)
      Setting.unstub(:[])
    end

    test 'set_advanced_setting works when setting is present' do
      setting_name = 'allow_auto_inventory_upload'
      Foreman.settings.stubs(:find).with(setting_name).returns(true)
      
      # Mock the setting assignment
      Setting.expects(:[]=).with(setting_name, true)
      
      # Mock settings for the response
      Setting.stubs(:[]).with(:subscription_connection_enabled).returns(true)
      Setting.stubs(:[]).with(:allow_auto_inventory_upload).returns(true)
      Foreman.settings.stubs(:find).with('insights_minimal_data_collection').returns(nil)
      Foreman.settings.stubs(:find).with('obfuscate_inventory_hostnames').returns(nil)
      Foreman.settings.stubs(:find).with('obfuscate_inventory_ips').returns(nil)
      Foreman.settings.stubs(:find).with('exclude_installed_packages').returns(nil)
      Foreman.settings.stubs(:find).with('allow_auto_insights_mismatch_delete').returns(nil)
      
      post :set_advanced_setting, 
           params: { setting: setting_name, value: 'true' }, 
           session: set_session_user
      
      assert_response :success
      
      Foreman.settings.unstub(:find)
      Setting.unstub(:[])
      Setting.unstub(:[]=)
    end
  end

  class InsightsSettingsProtectionTest < SettingsProtectionControllerTest
    tests InsightsCloud::SettingsController

    test 'show handles missing allow_auto_insights_sync setting' do
      Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(nil)
      
      get :show, session: set_session_user
      
      assert_response :success
      
      response_data = JSON.parse(response.body)
      assert_equal false, response_data['insightsSyncEnabled']
      
      Foreman.settings.unstub(:find)
    end

    test 'show returns actual value when setting is present' do
      Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(true)
      Setting.stubs(:[]).with(:allow_auto_insights_sync).returns(true)
      
      get :show, session: set_session_user
      
      assert_response :success
      
      response_data = JSON.parse(response.body)
      assert_equal true, response_data['insightsSyncEnabled']
      
      Foreman.settings.unstub(:find)
      Setting.unstub(:[])
    end

    test 'update ignores missing setting' do
      Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(nil)
      
      put :update, 
          params: { insightsSyncEnabled: 'true' }, 
          session: set_session_user
      
      assert_response :success
      
      response_data = JSON.parse(response.body)
      assert_equal false, response_data['insightsSyncEnabled']
      
      Foreman.settings.unstub(:find)
    end

    test 'update works when setting is present' do
      Foreman.settings.stubs(:find).with('allow_auto_insights_sync').returns(true)
      
      # Mock the setting assignment
      Setting.expects(:[]=).with(:allow_auto_insights_sync, true)
      Setting.stubs(:[]).with(:allow_auto_insights_sync).returns(true)
      
      put :update, 
          params: { insightsSyncEnabled: 'true' }, 
          session: set_session_user
      
      assert_response :success
      
      response_data = JSON.parse(response.body)
      assert_equal true, response_data['insightsSyncEnabled']
      
      Foreman.settings.unstub(:find)
      Setting.unstub(:[])
      Setting.unstub(:[]=)
    end
  end

  class UploadsControllerProtectionTest < SettingsProtectionControllerTest
    tests ForemanInventoryUpload::UploadsController

    test 'enable_cloud_connector ignores missing setting' do
      # Skip the before_action that checks for IoP
      ForemanInventoryUpload::UploadsController.any_instance.stubs(:require_non_iop_smart_proxy)
      
      Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(nil)
      
      # Mock cloud connector
      cloud_connector = mock('cloud_connector')
      cloud_connector.stubs(:install).returns({ 'status' => 'success' })
      ForemanRhCloud::CloudConnector.stubs(:new).returns(cloud_connector)
      
      post :enable_cloud_connector, session: set_session_user
      
      assert_response :success
      
      # The missing setting should not have been set
      # (This is implicitly tested by not stubbing Setting[]= and ensuring no error occurs)
      
      Foreman.settings.unstub(:find)
    end

    test 'enable_cloud_connector works when setting is present' do
      # Skip the before_action that checks for IoP
      ForemanInventoryUpload::UploadsController.any_instance.stubs(:require_non_iop_smart_proxy)
      
      Foreman.settings.stubs(:find).with('allow_auto_inventory_upload').returns(true)
      
      # Mock the setting assignment
      Setting.expects(:[]=).with(:allow_auto_inventory_upload, true)
      
      # Mock cloud connector
      cloud_connector = mock('cloud_connector')
      cloud_connector.stubs(:install).returns({ 'status' => 'success' })
      ForemanRhCloud::CloudConnector.stubs(:new).returns(cloud_connector)
      
      post :enable_cloud_connector, session: set_session_user
      
      assert_response :success
      
      Foreman.settings.unstub(:find)
      Setting.unstub(:[]=)
    end
  end
end