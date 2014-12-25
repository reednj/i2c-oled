require 'sinatra'
require 'socket'
require "sinatra/reloader" if development?
require '../gpio-helper'

HOST_NAME = Socket.gethostname || 'unknown'

set :environment, :production if HOST_NAME.start_with? 'raspberry'
set :is_on, false

GPIO = GPIONumeric.new

configure :production do
	set :bind, '0.0.0.0'
	set :port, 80
end

helpers do
	# basically the same as a regular halt, but it sends the message to the 
	# client with the content type 'text/plain'. This is important, because
	# the client error handlers look for that, and will display the message
	# if it is text/plain and short enough
	def halt_with_text(code, message = nil)
		halt code, {'Content-Type' => 'text/plain'}, message
	end
end

get '/' do
	erb :home
end

get '/set/:n' do |n|
	#halt_with_text 400, 'display not started' if !settings.is_on
	GPIO.set_number n.to_i
	200
end
