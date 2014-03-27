require 'sinatra/base'
require 'sucker_punch'
require 'redis'
require 'json'

require 'dotenv'
Dotenv.load unless ENV['RACK_ENV'] == 'production'

if !ENV["REDISCLOUD_URL"].nil?
	uri = URI.parse(ENV["REDISCLOUD_URL"])
	$redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
else
	$redis = Redis.new
end

Dir.glob('./workers/*') {|file| require file}

class App < Sinatra::Base

	get "/#{ENV['ENDPOINT']}" do
		UpdateNotifyListJob.new.async.perform
		SearchTwitterJob.new.async.perform
		EmeraldRSSJob.new.async.perform
		"Started"
	end

end    