class Deployment

  attr_reader :staging, :production

  def initialize(staging, production)
    @staging = staging
    @production = production
    ActionCable.server.broadcast 'deployment', clear: true
  end

  def upgrade
    ActionCable.server.broadcast 'deployment', message: 'Upgrading Resources', class: 'heading'
    heroku.upgrade('postgresql-production', 'heroku-postgresql:hobby-basic')
    heroku.upgrade('redis-volatile', 'heroku-redis:premium-0')
    heroku.upgrade('redis-persistent', 'heroku-redis:premium-0')
    heroku.upgrade('mailgun-production', 'mailgun:basic')
  end

  def downgrade
    ActionCable.server.broadcast 'deployment', message: 'Downgrading Resources', class: 'heading'
    heroku.downgrade('postgresql-production', 'heroku-postgresql:hobby-dev')
    heroku.downgrade('redis-volatile', 'heroku-redis:hobby-dev')
    heroku.downgrade('redis-persistent', 'heroku-redis:hobby-dev')
    heroku.downgrade('mailgun-production', 'mailgun:starter')
  end

  def launch
    ActionCable.server.broadcast 'deployment', message: 'Promoting Staging -> Production', class: 'heading'
    heroku.promote(staging, production)
  end

  private

    def heroku
      @heroku ||= Heroku.new(production)
    end

end
