class DeploymentController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create]

  http_basic_authenticate_with  name: Rails.application.credentials.username,
                                password: Rails.application.credentials.password,
                                only: [:create]

  def index; end

  def create
    DeploymentJob.perform_later
  end

end
