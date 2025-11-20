module Api
  module V2
    module RhCloud
      class VulnerabilitiesController < ::Api::V2::BaseController
        layout false

        before_action :set_org, :set_loc
        before_action :find_host, only: [:host_vulnerabilities]

        api :GET, '/rh_cloud/vulnerabilities', N_('List CVE vulnerabilities')
        def index
          forward_cloud_request('api/vulnerability/v1/cves')
        end

        api :GET, '/rh_cloud/vulnerabilities/:id', N_('Show a CVE vulnerability')
        param :id, String, required: true, desc: N_('CVE ID')
        def show
          forward_cloud_request("api/vulnerability/v1/cves/#{params[:id]}")
        end

        api :GET, '/hosts/:host_id/rh_cloud/vulnerabilities', N_('List CVE vulnerabilities for a host')
        param :host_id, :identifier, required: true, desc: N_('Host ID or name')
        def host_vulnerabilities
          host = find_host
          return unless host

          insights_uuid = host.insights&.uuid
          unless insights_uuid
            return render json: { message: 'Host does not have Insights UUID', error: 'No Insights facet found' }, status: :not_found
          end

          forward_cloud_request("api/vulnerability/v1/systems/#{insights_uuid}/cves")
        end

        private

        def find_host
          @host ||= resource_scope_for_index.find(params[:host_id])
        rescue ActiveRecord::RecordNotFound
          render json: { message: 'Host not found', error: "Host with id #{params[:host_id]} not found" }, status: :not_found
          nil
        end

        def resource_scope_for_index(options = {})
          @resource_scope_for_index ||= Host.authorized("#{action_permission}_hosts", Host)
        end

        def action_permission
          case params[:action]
          when 'host_vulnerabilities'
            :view
          else
            super
          end
        end

        def forward_cloud_request(path)
          begin
            @cloud_response = ::ForemanRhCloud::InsightsApiForwarder.new.forward_request(
              request,
              path,
              controller_name,
              User.current,
              @organization,
              @location
            )
          rescue RestClient::Exceptions::Timeout => e
            response_obj = e.response.presence || e.exception
            return render json: { message: response_obj.to_s, error: response_obj.to_s }, status: :gateway_timeout
          rescue RestClient::Unauthorized => e
            logger.warn("Forwarding request auth error: #{e}")
            message = 'Authentication to the Insights Service failed.'
            return render json: { message: message, error: message }, status: :unauthorized
          rescue RestClient::NotModified => e
            logger.info("Forwarding request not modified: #{e}")
            message = 'Cloud request not modified'
            return render json: { message: message, error: message }, status: :not_modified
          rescue RestClient::ExceptionWithResponse => e
            response_obj = e.response.presence || e.exception
            code = response_obj.try(:code) || response_obj.try(:http_code) || 500
            message = 'Cloud request failed'
            return render json: { message: message, error: response_obj.to_s, headers: {}, response: response_obj }, status: code
          rescue StandardError => e
            logger.warn("Cloud request failed with exception: #{e}")
            Foreman::Logging.exception("Vulnerabilities cloud request failed", e)
            return render json: { error: e.to_s }, status: :bad_gateway
          end

          # Append headers from cloud response
          @cloud_response.headers.each do |key, _value|
            assign_header(response, @cloud_response, key, false) if key.to_s.start_with?('x_rh_')
          end

          assign_header(response, @cloud_response, :x_resource_count, true)
          headers[Rack::ETAG] = @cloud_response.headers[:etag] if @cloud_response.headers[:etag]

          render json: @cloud_response, status: @cloud_response.code
        end

        def assign_header(response, cloud_response, key, allow_nil)
          value = cloud_response.headers[key]
          return unless value || allow_nil

          response.headers[key.to_s.upcase.tr('_', '-')] = value.to_s
        end

        def set_org
          @organization = if params[:organization_id]
                            Organization.find(params[:organization_id])
                          else
                            Organization.current
                          end
        rescue ActiveRecord::RecordNotFound
          render json: { message: 'Organization not found', error: "Organization with id #{params[:organization_id]} not found" }, status: :not_found
        end

        def set_loc
          @location = Location.current
        end

        def render_message(msg, status:)
          render json: { message: msg, error: msg }, status: status
        end
      end
    end
  end
end
