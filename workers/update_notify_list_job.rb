require 'httparty'
require 'json'

class UpdateNotifyListJob
  include SuckerPunch::Job

  	def perform
		response = HTTParty.get(
			"https://basecamp.com/#{ENV['BASECAMP_ACCOUNT_ID']}/api/v1/projects/#{ENV['BASECAMP_PROJECT_ID']}/accesses.json", 
			headers: {
				"User-Agent" => "EMG-NewsBot (ivong@dailyemerald.com)", 
				'Content-Type' => 'application/json'
			}, 
			basic_auth: { 
				username: ENV['BASECAMP_USERNAME'], 
				password: ENV['BASECAMP_PASSWORD'] 
			}	
		)

		notify_ids = JSON.parse(response.body).reject{ |user| 
			(ENV['DONT_NOTIFY'] || '').split(',').include?(user['email_address']) 
		}.map{ |user| 
			user['id']
		}.join(',')

		p "user_ids_to_notify: #{notify_ids}"

		$redis.set('user_ids_to_notify', notify_ids)
	end
end
