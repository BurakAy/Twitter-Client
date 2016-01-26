require "jumpstart_auth"

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
		  puts "You can only DM people who follow you"
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
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end # end run method



end # end class

blogger = MicroBlogger.new
blogger.run

# ruby micro_blogger.rb