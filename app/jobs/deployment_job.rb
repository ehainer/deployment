class DeploymentJob < ApplicationJob

  rescue_from(Deployment::DeployPending) { retry_job wait: 1.minute }

  def perform(task)
    if Setting.deploying
      raise Deployment::DeployPending, 'Deploy already running, waiting 1 minute to try again...'
    else
      Setting.deploying = true
      case task
        when 'upgrade'
          deployment.upgrade
        when 'downgrade'
          deployment.downgrade
        when 'maintenance'
          deployment.maintenance
      end
      Setting.deploying = false
    end
  end

  private

    def deployment
      @deployment ||= Deployment.new('motherboard-staging', 'motherboard-production')
    end

end
