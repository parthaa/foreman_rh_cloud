require 'test_plugin_helper'

module Api
  module V2
    module RhCloud
      class VulnerabilitiesControllerTest < ActionController::TestCase
        setup do
          @org = FactoryBot.create(:organization)
          @loc = FactoryBot.create(:location)
          Organization.current = @org
          Location.current = @loc

          @body = {
            'data' => [
              {
                'cve' => 'CVE-2024-1234',
                'synopsis' => 'Test vulnerability',
                'cvss_score' => 7.5
              }
            ],
            'meta' => {
              'count' => 1
            }
          }.to_json

          @http_req = mock('request')
          @http_req.stubs(:code).returns(200)
          net_http_resp = mock('net_http_resp')
          net_http_resp.stubs(:code).returns('200')
          net_http_resp.stubs(:header).returns({})

          @cloud_response = RestClient::Response.create(@body, net_http_resp, @http_req)
          @cloud_response.stubs(:headers).returns({
            etag: 'test-etag',
            x_resource_count: '1',
            x_rh_insights_request_id: 'test-request-id'
          })

          ::ForemanRhCloud::InsightsApiForwarder.any_instance.stubs(:forward_request).returns(@cloud_response)

          User.current = users(:admin)
        end

        test "should get index" do
          get :index, session: set_session_user
          assert_response :success
          assert_equal @body, @response.body
          assert_equal 'test-etag', @response.headers['ETAG']
          assert_equal '1', @response.headers['X-RESOURCE-COUNT']
          assert_equal 'test-request-id', @response.headers['X-RH-INSIGHTS-REQUEST-ID']
        end

        test "should get show" do
          get :show, params: { id: 'CVE-2024-1234' }, session: set_session_user
          assert_response :success
          assert_equal @body, @response.body
        end

        test "should handle timeout error" do
          error_response = RestClient::Response.create('timeout error', mock('net_http_resp'), @http_req)
          error = RestClient::Exceptions::Timeout.new(error_response)
          ::ForemanRhCloud::InsightsApiForwarder.any_instance.stubs(:forward_request).raises(error)

          get :index, session: set_session_user
          assert_response :gateway_timeout
        end

        test "should handle unauthorized error" do
          error = RestClient::Unauthorized.new
          ::ForemanRhCloud::InsightsApiForwarder.any_instance.stubs(:forward_request).raises(error)

          get :index, session: set_session_user
          assert_response :unauthorized
        end

        test "should handle not modified error" do
          error = RestClient::NotModified.new
          ::ForemanRhCloud::InsightsApiForwarder.any_instance.stubs(:forward_request).raises(error)

          get :index, session: set_session_user
          assert_response :not_modified
        end

        test "should handle standard error" do
          error = StandardError.new('something went wrong')
          ::ForemanRhCloud::InsightsApiForwarder.any_instance.stubs(:forward_request).raises(error)

          get :index, session: set_session_user
          assert_response :bad_gateway
        end

        context 'host_vulnerabilities action' do
          setup do
            @host = FactoryBot.create(:host, :managed, organization: @org, location: @loc)
            @insights_facet = FactoryBot.create(:insights_facet, host: @host, uuid: 'test-uuid-1234')
          end

          test "should get host vulnerabilities" do
            get :host_vulnerabilities, params: { host_id: @host.id }, session: set_session_user
            assert_response :success
            assert_equal @body, @response.body
          end

          test "should handle host not found" do
            get :host_vulnerabilities, params: { host_id: 'nonexistent' }, session: set_session_user
            assert_response :not_found
            assert_includes @response.body, 'Host not found'
          end

          test "should handle host without insights facet" do
            host_without_insights = FactoryBot.create(:host, :managed, organization: @org, location: @loc)
            get :host_vulnerabilities, params: { host_id: host_without_insights.id }, session: set_session_user
            assert_response :not_found
            assert_includes @response.body, 'Host does not have Insights UUID'
          end

          test "should handle timeout error for host vulnerabilities" do
            error_response = RestClient::Response.create('timeout error', mock('net_http_resp'), @http_req)
            error = RestClient::Exceptions::Timeout.new(error_response)
            ::ForemanRhCloud::InsightsApiForwarder.any_instance.stubs(:forward_request).raises(error)

            get :host_vulnerabilities, params: { host_id: @host.id }, session: set_session_user
            assert_response :gateway_timeout
          end

          test "should handle unauthorized error for host vulnerabilities" do
            error = RestClient::Unauthorized.new
            ::ForemanRhCloud::InsightsApiForwarder.any_instance.stubs(:forward_request).raises(error)

            get :host_vulnerabilities, params: { host_id: @host.id }, session: set_session_user
            assert_response :unauthorized
          end
        end
      end
    end
  end
end
