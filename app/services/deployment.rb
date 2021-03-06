class Deployment

  class DeployPending < StandardError; end

  attr_reader :staging, :production

  def initialize(staging, production)
    @staging = staging
    @production = production
  end

  def upgrade
    ActionCable.server.broadcast 'deployment', clear: true, message: 'Upgrading Resources', class: 'heading'
    heroku.upgrade('redis-volatile', 'heroku-redis:premium-0')
    heroku.upgrade('redis-persistent', 'heroku-redis:premium-0')
    heroku.upgrade('mailgun-production', 'mailgun:basic')

    ActionCable.server.broadcast 'deployment', message: 'Configuring Mailer', class: 'heading'
    Rails.application.credentials.mailgun.each { |key, value| heroku.env(key, value) }

    ActionCable.server.broadcast 'deployment', message: 'Upgrading Database', class: 'heading'
    heroku.provision('heroku-postgresql:hobby-basic')

    ActionCable.server.broadcast 'deployment', message: 'Scaling Up', class: 'heading'
    heroku.resize('hobby')

    ActionCable.server.broadcast 'deployment', message: 'Promoting Staging -> Production', class: 'heading'
    heroku.promote(staging, production)

    ActionCable.server.broadcast 'deployment', message: 'Migrating Database', class: 'heading'
    heroku.migrate

    ActionCable.server.broadcast 'deployment', message: 'Seeding Database', class: 'heading'
    heroku.seed

    heroku.secure

    ActionCable.server.broadcast 'deployment', message: 'Disabling Maintenance Mode', class: 'heading'
    heroku.maintenance(false)

    ActionCable.server.broadcast 'deployment', message: 'Launched! <a href="https://app.motherboardbirth.com" target="_blank">https://app.motherboardbirth.com</a>', class: 'heading complete'
  end

  def downgrade
    ActionCable.server.broadcast 'deployment', clear: true, message: 'Downgrading Resources', class: 'heading'
    heroku.downgrade('redis-volatile', 'heroku-redis:hobby-dev')
    heroku.downgrade('redis-persistent', 'heroku-redis:hobby-dev')
    heroku.downgrade('mailgun-production', 'mailgun:starter')

    ActionCable.server.broadcast 'deployment', message: 'Downgrading Database', class: 'heading'
    heroku.provision('heroku-postgresql:hobby-dev')

    ActionCable.server.broadcast 'deployment', message: 'Scaling Down', class: 'heading'
    heroku.resize('free')

    ActionCable.server.broadcast 'deployment', message: 'Enabling Maintenance Mode', class: 'heading'
    heroku.maintenance(true)

    ActionCable.server.broadcast 'deployment', message: 'Done!', class: 'heading complete'
  end

  def maintenance
    ActionCable.server.broadcast 'deployment', clear: true, message: 'Toggling Maintenance Mode', class: 'heading'
    h = Heroku.new(production)
    h.maintenance

    ActionCable.server.broadcast 'deployment', message: 'Done!', class: 'heading complete'
  end

  private

    def heroku
      @heroku ||= Heroku.new(production)
    end

end
