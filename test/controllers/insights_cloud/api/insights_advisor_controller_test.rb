require 'test_plugin_helper'

module InsightsCloud
  module Api
    class InsightsAdvisorControllerTest < ActionController::TestCase
      tests ::Api::V2::InsightsAdvisor::InsightsAdvisorController

      setup do
        @test_org = FactoryBot.create(:organization)
        @host1 = FactoryBot.create(:host, :with_insights_hits, organization: @test_org, hostname: 'insightshost1')
        @host2 = FactoryBot.create(:host, :with_insights_hits, organization: @test_org, hostname: 'insightshost2')
        @host3 = FactoryBot.create(:host, organization: @test_org)
      end

      test 'shows all hosts with no search param' do
        get :host_details, params: { organization_id: @test_org.id }

        assert_response :success
        assert_template 'api/v2/insights_advisor/host_details'
        assert_equal @test_org.hosts.count, assigns(:hosts).count
      end

      test 'shows hosts with search param' do
        search = @host1.name[0..4]
        get :host_details, params: { organization_id: @test_org.id, search: search }
        assert_response :success
        assert_template 'api/v2/insights_advisor/host_details'
        assert_equal @test_org.hosts.where('name LIKE ?', "%#{search}%").count, assigns(:hosts).count
        refute_equal @test_org.hosts.count, assigns(:hosts).count
      end

      test 'fails without org id' do
        response = get :host_details

        assert_includes response.body, 'Organization not found'
      end
    end
  end
end
