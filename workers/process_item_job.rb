require 'httparty'
require 'json'

class ProcessItemJob
  include SuckerPunch::Job

  def create_notification_for(key, data)

  	$redis.sadd('sent_keys', key) # "lock" it. if we don't get a 201, we'll remove this to retry. no rate limiting.

  	basecamp_project_id = ENV['BASECAMP_PROJECT_ID']
  	basecamp_account_id = ENV['BASECAMP_ACCOUNT_ID']
  	app_name = "EMG-NewsBot (ivong@dailyemerald.com)"
  	auth = { username: ENV['BASECAMP_USERNAME'], password: ENV['BASECAMP_PASSWORD'] }
  	body = { subject: "#{data[:thread]}: #{data[:contents]}", content: "#{data[:contents]}\r\n\r\n#{data[:link]}" }

	response = HTTParty.post(
		"https://basecamp.com/#{basecamp_account_id}/api/v1/projects/#{basecamp_project_id}/messages.json", 
		headers: {"User-Agent" => app_name, 'Content-Type' => 'application/json'}, 
		basic_auth: auth,
		body: body.to_json
	)
	if response.code != 201
		$redis.srem('sent_keys', key)
		raise "Failed to save: #{data}"
	end
  	
  end

  def perform(data)

  	key = "#{data[:source]}:#{data[:id]}"
  	if $redis.sismember("sent_keys", key)
  		p "'#{key}' already sent"
  	else
  		create_notification_for(key, data)
  	end

  end
end