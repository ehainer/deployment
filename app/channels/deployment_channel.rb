class DeploymentChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'deployment'
  end

  def unsubscribed
  end

end
