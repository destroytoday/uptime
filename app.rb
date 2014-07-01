require 'sinatra/base'
require 'sinatra/reloader'
require 'pingdom-client'

class Uptime < Sinatra::Base
  configure do
    set :views, settings.root + '/'
  end

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    def client
      @client ||= Pingdom::Client.new(
        username: ENV['PINGDOM_USERNAME'],
        password: ENV['PINGDOM_PASSWORD'],
        key: ENV['PINGDOM_KEY']
      )
    end
  end

  get '/' do
    check = client.check(ENV['PINGDOM_CHECK_ID'])

    begin
      last_date = check.last_error_time.to_date
    rescue
      last_date = check.created.to_date
    end

    erb :index, locals: {
      status: check.status,
      days_since_downtime: (Date.today - last_date).to_i
    }
  end
end
