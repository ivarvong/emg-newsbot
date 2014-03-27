require 'httparty'
class DisqusCommentsJob
	include SuckerPunch::Job

	def get_comments
		JSON.parse(
			HTTParty.get("https://disqus.com/api/3.0/forums/listPosts.json?forum=#{ENV['DISQUS_FORUM']}&api_key=#{ENV['DISQUS_PUBLIC_API_KEY']}").body
		)
	end

	def get_thread(thread_id)
		JSON.parse(
			HTTParty.get("https://disqus.com/api/3.0/threads/details.json?thread=#{thread_id}&api_key=#{ENV['DISQUS_PUBLIC_API_KEY']}").body		
		)
	end

	def perform
		comments = get_comments()['response']

		threads = comments.map{|comment| comment['thread']}
		threads.each do |thread|
			if $redis.get("disqus_thread:#{thread}").nil?
				p "fetching disqus thread #{thread}"
				$redis.set("disqus_thread:#{thread}", get_thread(thread).to_json)
			end
		end

		comments.each do |comment|
			thread = JSON.parse($redis.get("disqus_thread:#{comment['thread']}"))['response']
			ProcessItemJob.new.async.perform({
				source: 'disqus_comment', 
				id: comment['id'], 
				thread: "New Comment",
				title: thread['clean_title'],
				contents: "'#{comment['raw_message']}'\r\n\r\nPosted by: '#{comment['author']['name']}'", 
				link: thread['link']
			})
		end
		
	end
end