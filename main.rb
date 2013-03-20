io = Sinatra::RocketIO

## Arduino sensors
io.on :start do
  begin
    arduino = ArduinoFirmata.connect ENV['ARDUINO'], :eventmachine => true
  rescue => e
    STDERR.puts "#{e.class} - #{e}"
    next
  end
  EM::add_periodic_timer 0.3 do
    light = arduino.analog_read 0
    $logger.debug "light : #{light}"
    temp = arduino.analog_read(1).to_f*5*100/1024
    $logger.debug "temperature : #{temp}"
    io.push :arduino, :temp => temp, :light => light
  end
end

## CPU status
io.once :start do
  EM::add_periodic_timer 5 do
    stat = `ps aux`.split(/[\r\n]/).map{|i|
      i.split(/\s+/)[0...4]
    }.select{|i|
      i[1].to_i == Process.pid
    }[0]
    user, pid, cpu, mem, = stat
    $logger.debug "cpu:#{cpu}, mem:#{mem}"
    io.push :stat, {:cpu => cpu, :mem => mem}
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

helpers do
  def app_root
    "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
  end
end

get '/' do
  @title = "RocketIO+ArduinoFirmata"
  haml :index
end

get '/:source.css' do
  scss params[:source].to_sym
end
