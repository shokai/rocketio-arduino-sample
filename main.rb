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
    temp = arduino.analog_read(1).to_f*5*100/1024
    $logger.debug "temperature : #{temp}"
    io.push :arduino, :temp => temp, :light => light
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

io.once :start do
  EM::add_periodic_timer 10 do
    pid = Process.pid
    stat = `ps aux`.split(/[\r\n]/).map{|i|
      i.split(/\s+/)[0...4]
    }.select{|i|
      i[1].to_i == pid
    }[0]
    user, pid_, cpu, mem, = stat
    io.push :stat, {:cpu => cpu, :mem => mem}
  end
end

get '/' do
  @title = "RocketIO+ArduinoFirmata"
  haml :index
end

get '/:source.css' do
  scss params[:source].to_sym
end
