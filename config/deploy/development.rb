## Development
## =======

set :bundle_without, %w{production test}.join(' ')

set :branch, 'master'

server 'minow.io', user: fetch(:application), port: 1022, roles: %w{web app db}, primary: true
