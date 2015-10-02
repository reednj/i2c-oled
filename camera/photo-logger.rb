#!/usr/bin/env ruby

require 'time'
require 'rpi-camera'

def main()
	ph = PhotoHelper.new '/mnt/usb/rpi-camera/'
	
	loop do
		ph.capture
		sleep 60.0
	end
end


main()
