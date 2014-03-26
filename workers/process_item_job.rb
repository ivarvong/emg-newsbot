require 'httparty'
require 'json'

class ProcessItemJob
  include SuckerPunch::Job

  def create_notification_for(key, data)

  	$redis.sadd('sent_keys', key) # "lock" it. if we don't get a 201, we'll remove this to retry. no rate limiting.

  	body = { 
  		subject: "#{data[:thread]}: #{data[:contents]}", 
  		content: "#{data[:contents]}\r\n\r\n#{data[:link]}" 
  	}

	response = HTTParty.post(
		"https://basecamp.com/#{ENV['BASECAMP_ACCOUNT_ID']}/api/v1/projects/#{ENV['BASECAMP_PROJECT_ID']}/messages.json", 
		headers: {
			"User-Agent" => "EMG-NewsBot (ivong@dailyemerald.com)", 
			'Content-Type' => 'application/json'
		}, 
		basic_auth: { 
			username: ENV['BASECAMP_USERNAME'], 
			password: ENV['BASECAMP_PASSWORD'] 
		},
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