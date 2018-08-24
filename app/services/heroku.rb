require 'open3'

class Heroku

  attr_reader :app

  def initialize(app)
    @app = sanitize(app)
  end

  def status
    `heroku status`
  end

  def addons
    `heroku addons --app #{app}`
  end

  def upgrade(addon, tier)
    addon = sanitize(addon)
    tier = sanitize(tier)
    process "heroku addons:upgrade #{addon} #{tier} --app #{app}"
  end

  def downgrade(addon, tier)
    addon = sanitize(addon)
    tier = sanitize(tier)
    process "heroku addons:downgrade #{addon} #{tier} --app #{app}"
  end

  def promote(from, to)
    from = sanitize(from)
    to = sanitize(to)
    process "heroku pipelines:promote --app #{from} --to #{to}"
  end

  def resize(tier)
    tier = sanitize(tier)
    process "heroku dyno:resize #{tier} --app #{app}"
  end

  def migrate
    process "heroku run rake db:migrate --app #{app}"
  end

  def maintenance
    status = `heroku maintenance --app #{app}`
    if /on/ =~ status
      process "heroku maintenance:off --app #{app}"
    else
      process "heroku maintenance:on --app #{app}"
    end
  end

  def provision(tier)
    process "heroku ps:scale web=0 --app #{app}"
    process "heroku ps:scale sidekiq=0 --app #{app}"
    process "heroku addons:create #{tier} --version 9.6 --app #{app}"
    process "heroku pg:wait --app #{app}"
    result = process "heroku pg:info --app #{app}"
    new_database = (result.match(/\b(HEROKU_POSTGRESQL_[A-Z_]+)_URL/) || [])[1]

    if new_database.present?
      process "heroku pg:copy DATABASE_URL #{new_database} --app #{app} --confirm #{app}"
      process "heroku pg:wait --app #{app}"
      process "heroku pg:promote #{new_database} --app #{app}"

      result = process "heroku pg:info --app #{app}"
      old_database = (result.match(/\b(HEROKU_POSTGRESQL_[A-Z_]+)_URL/) || [])[1]

      process "heroku addons:destroy #{old_database} --app #{app}" if old_database.present?
    end

    process "heroku ps:scale sidekiq=1 --app #{app}"
    process "heroku ps:scale web=1 --app #{app}"
  end

  private

    def sanitize(text)
      text.gsub(/[^a-z\-:0-9]+/, '')
    end

    def process(command)
      response = ''
      Open3.popen3(command) do |stdin, stdout, stderr, status, thread|
        read_stream, = IO.select([stdout, stderr])

        read_stream.each do |stream|
          while line = stream.gets do
            response += line
            ActionCable.server.broadcast 'deployment', message: line
          end
        end
      end
      response
    end

end
