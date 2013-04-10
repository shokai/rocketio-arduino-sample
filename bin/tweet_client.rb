#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'bundler/setup'
require 'sinatra/rocketio/client'
require 'tw'
require 'args_parser'

parser = ArgsParser.parse ARGV do
  arg :url, 'RocketIO URL', :default => 'http://localhost:5000'
  arg :tweet, 'twitter User name', :default => 'shokai'
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help or !parser.has_param? :url or !parser.has_param? :tweet
  STDERR.puts parser.help
  STDERR.puts
  STDERR.puts "e.g.  #{$0} --url http://localhost:5000 --tweet shokai"
  exit 1
end

tw = Tw::Client.new
tw.auth parser[:tweet]

puts "#{parser[:url]} waiting.."
io = Sinatra::RocketIO::Client.new(parser[:url]).connect

io.on :connect do
  puts "#{io.type} connect <#{io.session}>"
end

io.on :disconnect do |err|
  puts "disconnect!!"
  p err
  exit 1
end

io.on :arduino do |data|
  puts "arduino : #{data.inspect}"
  puts "light : #{data['light']}"
  puts "temp : #{data['temp']}"
  msg = {'気温' => data['temp'], '明るさ' => data['light']}
  tw.tweet msg.to_json
  exit
end

io.on :error do |err|
  p err
  exit 1
end

loop do
end
