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
		
		server = 'reednj@reednj.com'
		remote = "#{server}:#{remote_path}"
		ph = PhotoHelper.new '~/photos', :simple => true
		
		display.set 'foto'
		ph.capture
		puts "photo saved at #{ph.output_path}"
		
		display.set 'send'
		`scp #{ph.output_path} #{remote}`
		`ssh #{server} 'cp #{remote_path} ~/reednj.com/rpi.jpg'`
		puts "uploaded to #{remote}"

		display.set 'done'
		sleep 1.0
		display.release_display
	end

	def remote_path
		 @remote_path = "~/rpi/pics/#{Time.now.utc.iso8601}.jpg".gsub(':', '.') if @remote_path.nil?
		 @remote_path
	end
end

App.new.main
