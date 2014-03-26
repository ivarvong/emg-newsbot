require 'twitter'
class SearchTwitterJob
	include SuckerPunch::Job

	def perform
		client = Twitter::REST::Client.new do |config|
			config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
			config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
			config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
			config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
		end
		client.search("dailyemerald", :result_type => "recent").take(20).each do |tweet|			
			ProcessItemJob.new.async.perform({
				source: 'twittersearch', 
				id: tweet.id, 
				thread: "Twitter Mentions", 
				contents: tweet.text, 
				link: tweet.uri
			})
		end
	end
end