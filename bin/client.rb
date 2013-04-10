#!/usr/bin/env ruby
#require 'bundler'
require 'sinatra/rocketio/client'

url = ARGV.shift || 'http://localhost:5000'
type = ARGV.shift || :websocket  # :comet or :websocket

io = Sinatra::RocketIO::Client.new(url, :type => type).connect
puts "#{io.url} waiting.."

io.on :connect do
  puts "#{io.type} connect <#{io.session}>"
end

io.on :arduino do |data|
  puts "arduino : #{data.inspect}"
end

io.on :stat do |data|
  puts "stat : #{data.inspect}"
end

io.on :disconnect do |err|
  puts "disconnect!!"
  p err
end

io.on :error do |err|
  p err
end

loop do
end
