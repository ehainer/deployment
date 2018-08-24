class Deployment

  class DeployPending < StandardError; end

  attr_reader :staging, :production

  def initialize(staging, production)
    @staging = staging
    @production = production
  end

  def upgrade
    ActionCable.server.broadcast 'deployment', message: 'Upgrading Resources', class: 'heading'
    heroku.upgrade('postgresql-production', 'heroku-postgresql:hobby-basic')
    heroku.upgrade('redis-volatile', 'heroku-redis:premium-0')
    heroku.upgrade('redis-persistent', 'heroku-redis:premium-0')
    heroku.upgrade('mailgun-production', 'mailgun:basic')

    ActionCable.server.broadcast 'deployment', message: 'Resizing Dyno -> hobby', class: 'heading'
    heroku.resize('hobby')

    migrate
    launch

    ActionCable.server.broadcast 'deployment', message: 'Deployed!', class: 'heading complete'
  end

  def downgrade
    ActionCable.server.broadcast 'deployment', message: 'Downgrading Resources', class: 'heading'
    heroku.downgrade('postgresql-production', 'heroku-postgresql:hobby-dev')
    heroku.downgrade('redis-volatile', 'heroku-redis:hobby-dev')
    heroku.downgrade('redis-persistent', 'heroku-redis:hobby-dev')
    heroku.downgrade('mailgun-production', 'mailgun:starter')

    ActionCable.server.broadcast 'deployment', message: 'Resizing Dyno -> free', class: 'heading'
    heroku.resize('free')

    ActionCable.server.broadcast 'deployment', message: 'Done!', class: 'heading complete'
  end

  def launch
    ActionCable.server.broadcast 'deployment', message: 'Promoting Staging -> Production', class: 'heading'
    heroku.promote(staging, production)
  end

  def migrate
    ActionCable.server.broadcast 'deployment', message: 'Migrating Database', class: 'heading'
    heroku.migrate
  end

  def maintenance
    ActionCable.server.broadcast 'deployment', message: 'Toggling Maintenance Mode', class: 'heading'
    h = Heroku.new(production)
    h.maintenance

    ActionCable.server.broadcast 'deployment', message: 'Done!', class: 'heading complete'
  end

  private

    def heroku
      @heroku ||= Heroku.new(production)
    end

end
