require 'pty'
require './lib/helpers'
require './lib/oled'

class App
	def main
		PTY.spawn 'sh' do |r, w, pid|
			puts 'starting...'
			sleep(2)

			loop do
				stream(STDIN, w)
				stream(r, STDOUT)
				sleep(0.1)
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

