#!/usr/bin/env ruby

require 'time'

def main()
	ph = PhotoHelper.new '/mnt/usb/rpi-camera/'
	
	loop do
		ph.capture
		sleep 60.0
	end
end

class PhotoHelper
	def initialize(root_path)
		@root_path = root_path
	end

	def capture
		`raspistill -o #{self.output_path} -w 1024 -h 768 -t 50 -vf -hf`
	end

	def output_path
		path = File.join @root_path, Time.now.iso_date
		Dir.mkdir path if !Dir.exist? path
		return File.join path, "#{Time.now.hour}.#{Time.now.min}.#{Time.now.sec}.jpg"
	end
end

class Time
	def iso_date
		"#{year}-#{month}-#{day}"
	end
end

main()
