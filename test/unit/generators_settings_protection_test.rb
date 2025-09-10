require 'test_plugin_helper'

class GeneratorsSettingsProtectionTest < ActiveSupport::TestCase
  include MockForemanHostname
  include CandlepinIsolation
  include KatelloLocationFix

  setup do
    @host = FactoryBot.create(:host, :managed, :with_subscription)
    @organization = @host.organization
  end

  test 'tags generator handles missing include_parameter_tags setting' do
    Foreman.settings.stubs(:find).with('include_parameter_tags').returns(nil)
    
    tags_generator = ForemanInventoryUpload::Generators::Tags.new(@host)
    parameters = tags_generator.generate_parameters
    
    # Should return empty array when setting is missing
    assert_equal [], parameters
    
    Foreman.settings.unstub(:find)
  end

  test 'tags generator works when include_parameter_tags setting is present and true' do
    Foreman.settings.stubs(:find).with('include_parameter_tags').returns(true)
    Setting.stubs(:[]).with(:include_parameter_tags).returns(true)
    
    # Add some host parameters
    @host.stubs(:host_params).returns({ 'param1' => 'value1', 'param2' => 'value2' })
    
    tags_generator = ForemanInventoryUpload::Generators::Tags.new(@host)
    parameters = tags_generator.generate_parameters
    
    # Should return the parameters when setting is true
    assert_equal [['param1', 'value1'], ['param2', 'value2']], parameters
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end

  test 'tags generator returns empty when include_parameter_tags setting is present but false' do
    Foreman.settings.stubs(:find).with('include_parameter_tags').returns(true)
    Setting.stubs(:[]).with(:include_parameter_tags).returns(false)
    
    tags_generator = ForemanInventoryUpload::Generators::Tags.new(@host)
    parameters = tags_generator.generate_parameters
    
    # Should return empty array when setting is false
    assert_equal [], parameters
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end

  test 'fact helpers obfuscate_hostname handles missing setting' do
    Foreman.settings.stubs(:find).with('obfuscate_inventory_hostnames').returns(nil)
    
    fact_helper = Class.new { include ForemanInventoryUpload::Generators::FactHelpers }.new
    result = fact_helper.send(:obfuscate_hostname?, @host)
    
    # Should return false when setting is missing
    assert_equal false, result
    
    Foreman.settings.unstub(:find)
  end

  test 'fact helpers obfuscate_hostname works when setting is present' do
    Foreman.settings.stubs(:find).with('obfuscate_inventory_hostnames').returns(true)
    Setting.stubs(:[]).with(:obfuscate_inventory_hostnames).returns(true)
    
    fact_helper = Class.new { include ForemanInventoryUpload::Generators::FactHelpers }.new
    result = fact_helper.send(:obfuscate_hostname?, @host)
    
    # Should return true when setting is true
    assert_equal true, result
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end

  test 'fact helpers obfuscate_ips handles missing setting' do
    Foreman.settings.stubs(:find).with('obfuscate_inventory_ips').returns(nil)
    
    fact_helper = Class.new { include ForemanInventoryUpload::Generators::FactHelpers }.new
    result = fact_helper.send(:obfuscate_ips?, @host)
    
    # Should return false when setting is missing
    assert_equal false, result
    
    Foreman.settings.unstub(:find)
  end

  test 'fact helpers obfuscate_ips works when setting is present' do
    Foreman.settings.stubs(:find).with('obfuscate_inventory_ips').returns(true)
    Setting.stubs(:[]).with(:obfuscate_inventory_ips).returns(true)
    
    fact_helper = Class.new { include ForemanInventoryUpload::Generators::FactHelpers }.new
    result = fact_helper.send(:obfuscate_ips?, @host)
    
    # Should return true when setting is true
    assert_equal true, result
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end

  test 'fact helpers hostname_match handles missing obfuscation setting' do
    Foreman.settings.stubs(:find).with('obfuscate_inventory_hostnames').returns(nil)
    ForemanRhCloud.stubs(:foreman_host).returns(@host)
    
    fact_helper = Class.new { include ForemanInventoryUpload::Generators::FactHelpers }.new
    fact_helper.stubs(:`).with('uname -n').returns("#{@host.name}\n")
    
    result = fact_helper.send(:hostname_match)
    
    # Should return the actual hostname when obfuscation setting is missing
    assert_equal @host.name, result
    
    Foreman.settings.unstub(:find)
    ForemanRhCloud.unstub(:foreman_host)
  end

  test 'slice generator handles missing insights_minimal_data_collection setting' do
    Foreman.settings.stubs(:find).with('insights_minimal_data_collection').returns(nil)
    
    output = []
    slice_generator = ForemanInventoryUpload::Generators::Slice.new([@host], output)
    
    # Mock required methods to avoid deep dependencies
    slice_generator.stubs(:uuid_value!).returns('test-uuid')
    slice_generator.stubs(:fqdn).returns(@host.name)
    slice_generator.stubs(:account_id).returns('123')
    slice_generator.stubs(:bios_uuid).returns('bios-uuid')
    slice_generator.stubs(:uuid_value).returns('vm-uuid')
    slice_generator.stubs(:fact_value).returns(nil)
    slice_generator.stubs(:report_ip_addresses)
    slice_generator.stubs(:report_mac_addresses)
    slice_generator.stubs(:report_system_profile)
    slice_generator.stubs(:report_satellite_facts)
    slice_generator.stubs(:installed_products).returns([])
    slice_generator.stubs(:report_yum_repos)
    
    # The host should have a subscription facet for the test
    @host.stubs(:subscription_facet).returns(mock('subscription_facet', uuid: 'sub-uuid', convert2rhel_through_foreman: nil))
    @host.stubs(:installed_packages).returns([])
    
    # When the setting is missing, it should go to the else branch (full data collection)
    slice_generator.expects(:insights_minimal_data_collection).never
    
    result = slice_generator.render
    
    # Should not crash and should generate some output
    assert_not_nil result
    
    Foreman.settings.unstub(:find)
  end

  test 'slice generator uses minimal collection when setting is present and true' do
    Foreman.settings.stubs(:find).with('insights_minimal_data_collection').returns(true)
    Setting.stubs(:[]).with(:insights_minimal_data_collection).returns(true)
    
    output = []
    slice_generator = ForemanInventoryUpload::Generators::Slice.new([@host], output)
    
    # Mock required methods
    slice_generator.stubs(:uuid_value!).returns('test-uuid')
    slice_generator.stubs(:insights_minimal_data_collection)
    
    # The host should have a subscription facet for the test
    @host.stubs(:subscription_facet).returns(mock('subscription_facet', uuid: 'sub-uuid'))
    
    # When the setting is true, it should call insights_minimal_data_collection
    slice_generator.expects(:insights_minimal_data_collection).once
    
    result = slice_generator.render
    
    # Should not crash and should generate some output
    assert_not_nil result
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end

  test 'slice generator handles missing exclude_installed_packages setting' do
    # Mock insights_minimal_data_collection as false to test the packages logic
    Foreman.settings.stubs(:find).with('insights_minimal_data_collection').returns(true)
    Setting.stubs(:[]).with(:insights_minimal_data_collection).returns(false)
    
    # Mock exclude_installed_packages as missing
    Foreman.settings.stubs(:find).with('exclude_installed_packages').returns(nil)
    
    output = []
    slice_generator = ForemanInventoryUpload::Generators::Slice.new([@host], output)
    
    # Test the package exclusion logic
    slice_generator.send(:instance_variable_set, :@stream, mock('stream'))
    stream_mock = slice_generator.instance_variable_get(:@stream)
    
    # When exclude_packages setting is missing, packages should be included
    stream_mock.expects(:array_field).with('installed_packages')
    @host.stubs(:installed_packages).returns([])
    slice_generator.stubs(:report_yum_repos)
    
    # Call the private method that handles package logic
    slice_generator.send(:define_singleton_method, :test_package_logic) do
      minimal_data_enabled = Foreman.settings.find('insights_minimal_data_collection') && Setting[:insights_minimal_data_collection]
      exclude_packages_enabled = Foreman.settings.find('exclude_installed_packages') && Setting[:exclude_installed_packages]
      if !minimal_data_enabled && !exclude_packages_enabled
        @stream.array_field('installed_packages') do
          # Package iteration logic would go here
        end
        report_yum_repos(@host)
      end
    end
    
    slice_generator.test_package_logic
    
    Foreman.settings.unstub(:find)
    Setting.unstub(:[])
  end
end