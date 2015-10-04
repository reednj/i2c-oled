#!/usr/bin/env ruby

require 'time'
require_relative './rpi-camera'
require_relative '../i2c/lib/alpha'

def main()
	display = AlphaDisplayShared.new
	
	server = 'reednj@reednj.com'
	remote = "#{server}:~/reednj.com/#{remote_path}"
	ph = PhotoHelper.new '~/photos', :simple => true
	
	display.set 'foto'
	ph.capture
	puts "photo saved at #{ph.output_path}"
	
	display.set 'send'
	`scp #{ph.output_path} #{remote}`
	`ssh #{server} 'unlink rpi.jpg;ln -s #{remote_path} rpi.jpg'`
	puts "uploaded to #{remote}"

	display.set 'done'
	sleep 1.0
	display.release_display
end

def remote_path
	 "pics/#{Time.now.utc.iso8601}.jpg"
end

main()
