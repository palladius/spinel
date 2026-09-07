module Api
  module V1
    class AuthController < ActionController::API
      def create
        name = params[:name].presence || "Personal Vault"
        vault = Vault.create!(name: name)
        render json: {
          vault_id: vault.id,
          name: vault.name,
          api_key: vault.api_key,
          created_at: vault.created_at
        }, status: :created
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
