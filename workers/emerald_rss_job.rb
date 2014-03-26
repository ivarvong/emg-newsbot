require 'open-uri'
require 'rss'
class EmeraldRSSJob
  include SuckerPunch::Job

  def perform
  	source = 'emeraldrss'
	open("http://dailyemerald.com/feed") do |rss|
		feed = RSS::Parser.parse(rss)
		feed.items.each do |item|
			post_id = item.guid.to_s.split('dailyemerald.com/?p=')[1].gsub('</guid>', '')
			title = item.title
			link = item.link
			ProcessItemJob.new.async.perform({
				source: source, 
				id: post_id, 
				thread: 'Posts (RSS)', 
				contents: title, 
				link: link
			})
		end
	end    
  end
end
