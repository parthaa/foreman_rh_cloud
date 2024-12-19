module Api
  module V2
    module InsightsAdvisor
      class InsightsAdvisorController < ::Api::V2::BaseController
        include ::Api::Version2

        before_action :find_organization

        def host_details
          @hosts = ::Host::Managed.search_for(params[:search] || "", :order => params[:order]).where(:organization_id => @organization.id).includes(:insights)
          respond_to do |format|
            format.json { render 'api/v2/insights_advisor/host_details' }
          end
        end

        private

        def find_organization
          @organization ||= Organization.find_by(label: params[:organization_label]) if params[:organization_label]
          @organization ||= Organization.find_by(label: params[:organization]) if params[:organization]
          @organization ||= Organization.find(params[:organization_id]) if params[:organization_id]
          raise ::Foreman::Exception.new(N_("Organization not found")) unless @organization
        end
      end
    end
  end
end
