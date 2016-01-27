require "jumpstart_auth"
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		if message.length <= 140
		  	@client.update(message)
		else
			puts "Message is greater than 140 characters"
		end
	end

	def dm(target, message)
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		if screen_names.include?(target) # check to see if user is a follower
		  puts "Trying to send #{target} this direct message"
		  puts message
		  message = "d @#{target} #{message}"
		  tweet(message)
		else
		  puts "You can only direct message people who follow you"
		end
	end

	def followers_list
		screen_names = []

		@client.followers.each do |follower|
		screen_names << @client.user(follower).screen_name # iterate through followers and push to array
		end

		return screen_names
	end

	def spam_my_followers(message)
		if message == ""
			puts "*** Please enter a message to spam your followers with ***"
		else
			followers_list.each { |follower| dm(follower, message) } # send a message to all of your followers
		end
	end

	def everyones_last_tweet # method for finding the last tweet for each of the people you follow
		friends = @client.friends.sort_by { |friend| friend.screen_name.downcase }
		friends.each do |friend|
			timestamp = friend.status.created_at
			puts "#{friend.screen_name} said this on #{timestamp.strftime("%A, %b %d")}\n #{friend.status.text}"
			puts ""
		end
	end

	def shorten(original_url)
		# shortening url
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		u = bitly.shorten(original_url).short_url

		puts "Shortening this URL: #{original_url}"

		return u
	end

	def run
		puts "*** Welcome to the JSL Twitter Client ***"

		command = ""
		while command != 'q'
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			
			# user commands
			case command
				when 'q' then puts "Goodbye!"
				when 't' then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'last' then everyones_last_tweet
				when 's' then shorten(parts[-1])
				when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end # end run method



end # end class

blogger = MicroBlogger.new
blogger.run

# ruby micro_blogger.rb