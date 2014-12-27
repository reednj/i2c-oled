require_relative 'lib/alpha'

display = AlphaDisplayShared.new
update_loop do
	display.set Time.now
end
