#!/usr/bin/env ruby

require 'time'
require_relative './rpi-camera'
require_relative '../i2c/lib/alpha'

class App
	def initialize
		@remote_path = nil
	end

	def main
		display = AlphaDisplayShared.new
		
		ph = PhotoHelper.new '~/photos', :simple => true
		
		display.set 'foto'
		ph.capture
		puts "photo saved at #{ph.output_path}"
		
		#display.set 'save'
		#self.store(ph.output_path)

		display.set 'save'
		self.tweet(ph.output_path)

		puts "upload complete"

		display.set 'done'
		sleep 1.0
		display.release_display
	end

	def store(output_path)
		server = SSHCmd.new('reednj@reednj.com')
		server.scp(output_path, remote_path)
		server.exec("cp #{remote_path} ~/reednj.com/rpi.jpg")
	end

	def tweet(output_path)
		twitter_account = 'pi_fotobot'
		tweet_time = Time.now.strftime("%A, %H:%M")
		text = "#{tweet_time} #raspberrypi"

		server = SSHCmd.new('reednj@paint.reednj.com')
		server.scp(output_path, remote_path)
		server.exec([
			"t set active #{twitter_account}",
			"t update -f #{remote_path} \"#{text}\""
		])
	end

	def remote_path
		 @remote_path = "~/rpi/pics/#{Time.now.utc.iso8601}.jpg".gsub(':', '.') if @remote_path.nil?
		 @remote_path
	end
end

class SSHCmd
	def initialize(server)
		@server = server
	end

	def exec(cmd)
		cmd = cmd.join ';' if cmd.is_a? Array
		`ssh #{@server} '#{cmd}'`
	end

	def scp(from, to)
		`scp #{from} #{@server}:#{to}`
	end
end

App.new.main
