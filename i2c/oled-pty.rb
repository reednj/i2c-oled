require 'pty'
require './lib/helpers'
require './lib/oled'

class App
	def main
		display = OLEDDisplay.new

		PTY.spawn 'sh' do |r, w, pid|
			puts 'starting...'
			sleep(1)

			loop do
				stream(STDIN, w)
				stream(r, display)
				sleep(0.1)

				display.write_line_buffer
				display.write_buffer
				display.clear_buffer
			end

		end
	end

	def stream(from, to)
		c = from.read_c
		while !c.nil?
			to.print c
			c = from.read_c
		end
	end

end

class IO
	def read_c
		begin
			return self.read_nonblock 1
		rescue IO::WaitReadable
			return nil
		end
	end
end

App.new.main

