#!/usr/bin/env ruby

require 'time'
require './rpi-camera'

def main()
	remote = 'reednj.com:~/reednj.com/rpi.jpg'
	ph = PhotoHelper.new '~/photos', :simple => true
	
	ph.capture
	puts "photo saved at #{ph.output_path}"
	
	`scp #{ph.output_path} #{remote}`
	puts "uploaded to #{remote}"
end

main()
