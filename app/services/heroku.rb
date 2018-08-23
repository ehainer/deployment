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
    if /off/ =~ status
      process "heroku maintenance:on --app #{app}"
    else
      process "heroku maintenance:off --app #{app}"
    end
  end

  private

    def sanitize(text)
      text.gsub(/[^a-z\-:0-9]+/, '')
    end

    def process(command)
      Open3.popen3(command) do |stdin, stdout, stderr, status, thread|
        read_stream, = IO.select([stdout, stderr])

        read_stream.each do |stream|
          while line = stream.gets do
            ActionCable.server.broadcast 'deployment', message: line
          end
        end
      end
    end

end
