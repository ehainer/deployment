class DeploymentController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create]

  http_basic_authenticate_with  name: Rails.application.credentials.username,
                                password: Rails.application.credentials.password,
                                only: [:create]

  def index; end

  def create
    now = Time.current

    if Setting.pending
      Setting.pending = false
      ActionCable.server.broadcast 'deployment', reset: true
    else
      if task.present? && !Setting.deploying
        ActionCable.server.broadcast 'deployment', clear: true
        sleep 1
        if ['upgrade', 'downgrade'].include?(task)
          # Launch / Downgrade action
          heroku = Heroku.new('motherboard-production')
          if heroku.status == task
            ActionCable.server.broadcast 'deployment', clear: true, warning: "Application is already #{state_past}. Try a different action.", class: 'heading complete warning'
          else
            ActionCable.server.broadcast 'deployment', clear: true, warning: "#{state_future} Motherboard Birth in 30 seconds... Press button again to cancel.", class: 'heading warning'
            DeploymentJob.set(wait: 30.seconds).perform_later(task, now.iso8601)
            Setting.pending = true
          end
        else
          # Maintenance action
          DeploymentJob.perform_later(task, now.iso8601)
        end
      end
    end

    Setting.cancel = now - 1.second

    head :ok
  end

  private

    def task
      ['upgrade', 'downgrade', 'maintenance'].find { |t| t == params[:task] }
    end

    def state_past
      case task
        when 'upgrade'
          return 'launched'
        when 'downgrade'
          return 'downgraded'
      end
    end

    def state_future
      case task
        when 'upgrade'
          return 'Hold on to your butts, launching'
        when 'downgrade'
          return 'Downgrading'
      end
    end

end
