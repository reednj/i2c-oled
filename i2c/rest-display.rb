require 'rest-client'
require_relative 'lib/alpha'

config = {
	:url => 'http://admin:Hamb0rG@reddit-stream.com/admin/info/revenue/this_month',
	:update_delay => 5.minutes,
	:is_number  => true
}

display = AlphaDisplayShared.new
is_number = config[:is_number] || true

update_loop(config[:update_delay]) do
	data = RestClient.get config[:url]
	data = data.to_f if is_number
	display.set data
	puts data.to_alpha
end
