require 'pty'
require './lib/helpers'
require './lib/oled'

class App
	def main
		@display = OLEDDisplay.new

		begin
			# we need to set the local tty to raw mode, so that the keystrokes
			# get sent through to the display without buffering
			`stty raw -echo`

			start_pty 'sh'
		rescue Errno::EIO
			@display.puts 'process finished'
			@display.flush
		ensure
			`stty -raw echo`
		end
	end

	def start_pty(cmd)
		PTY.spawn cmd do |r, w, pid|
			puts "#{cmd} started as #{pid}...\n\r"

			loop do
				stream(STDIN, w)
				stream(r, @display)

				sleep(0.01)
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

App.new.main
