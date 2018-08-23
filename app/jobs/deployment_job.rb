class DeploymentJob < ApplicationJob

  def perform
    deploy = Deployment.new('motherboard-staging', 'motherboard-production')
    deploy.upgrade
    sleep 30
    deploy.downgrade
  end

end