module Api
  module V1
    class HealthController < ActionController::API
      def show
        render json: {
          status: "healthy",
          service: "spinel-rails-api",
          version: "0.2.2",
          timestamp: Time.current.iso8601
        }
      end
    end
  end
end
