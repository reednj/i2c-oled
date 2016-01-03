require 'pty'
require './lib/helpers'
require './lib/oled'

class App
	def main
		display = OLEDDisplay.new

		PTY.spawn 'sh' do |r, w, pid|
			puts 'starting...'

			loop do
				stream(STDIN, w)
				stream(r, display)
				
				display.write_line_buffer
				display.write_buffer
				display.clear_buffer

				sleep(0.1)
			end

		end
	end

	def stream(from, to)
		s = nil
		c = from.read_c
		while !c.nil?
			s = '' if s.nil?
			s += c
			to.print c
			c = from.read_c
		end

		to.flush if to.respond_to? :flush
		return s
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

begin
	`stty raw -echo`
	App.new.main
ensure
	`stty -raw echo`
end


