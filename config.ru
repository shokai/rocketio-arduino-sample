require 'rubygems'
require 'bundler/setup'
Bundler.require
if development?
  $stdout.sync = true
  require 'sinatra/reloader'
end
require 'sinatra/rocketio'
require File.expand_path 'main', File.dirname(__FILE__)

set :haml, :escape_html => true
set :websocketio, :port => (ENV['WS_PORT'].to_i || 8080)
set :rocketio, :websocket => true, :comet => true

run Sinatra::Application
