#!/usr/bin/env ruby

require 'time'
require_relative './rpi-camera'
require_relative '../i2c/lib/alpha'

def main()
	display = AlphaDisplayShared.new
	remote = 'reednj@reednj.com:~/reednj.com/rpi.jpg'
	ph = PhotoHelper.new '~/photos', :simple => true
	
	display.set 'foto'
	ph.capture
	puts "photo saved at #{ph.output_path}"
	
	display.set 'send'
	`scp #{ph.output_path} #{remote}`
	puts "uploaded to #{remote}"

	display.release_display
end

main()
