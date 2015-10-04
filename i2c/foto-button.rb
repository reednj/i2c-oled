#!/usr/bin/env ruby

require_relative './lib/gpio'

def main
	GPIOInput.pull_up_3.on_key_down do
		puts `sudo -u reednj ruby /home/reednj/rpi/camera/webcam.rb`
	end
end

main()
