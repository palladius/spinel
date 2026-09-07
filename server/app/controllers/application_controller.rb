class ApplicationController < ActionController::API
  before_action :authenticate_vault!

  attr_reader :current_vault

  private

  def authenticate_vault!
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last

    if token.present?
      @current_vault = Vault.find_by(api_key: token)
    end

    render json: { error: "Unauthorized: Invalid or missing API key" }, status: :unauthorized unless @current_vault
  end
end
