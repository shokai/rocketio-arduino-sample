helpers do
  def app_root
    "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
  end
end

io = Sinatra::RocketIO

EM::defer do
  arduino = ArduinoFirmata.connect ENV['ARDUINO'], :eventmachine => true
  EM::add_periodic_timer 0.3 do
    light = arduino.analog_read 0
    $logger.debug "light : #{light}"
    io.push :light, light
    temp = arduino.analog_read(1).to_f*5*100/1024
    $logger.debug "temperature : #{temp}"
    io.push :temp, temp
  end
end

io.on :connect do |session, type|
  $logger.debug "new #{type} client <#{session}>"
  io.push :clients, {
    :websocket => Sinatra::WebSocketIO.sessions.size,
    :comet => Sinatra::CometIO.sessions.size
  }
end

io.on :disconnect do |session, type|
  $logger.debug "leave #{type} client #{session}"
  io.push :clients, {
    :websocket => Sinatra::WebSocketIO.sessions.size,
    :comet => Sinatra::CometIO.sessions.size
  }
end

get '/' do
  @title = "sensors"
  haml :index
end

get '/:source.css' do
  scss params[:source].to_sym
end
