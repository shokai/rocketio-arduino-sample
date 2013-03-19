io = Sinatra::RocketIO

EM::defer do
  puts "start!!!"
  arduino = ArduinoFirmata.connect ENV['ARDUINO']
  loop do
    light = arduino.analog_read 0
    puts "light #{light}"
    io.push :light, light
    temp = arduino.analog_read(1).to_f*5*100/1024
    puts "temp #{temp}"
    io.push :temp, temp
    sleep 0.1
  end
end

io.on :connect do |session, type|
  puts "new #{type} client <#{session}>"
end

io.on :disconnect do |session, type|
  puts "leave #{type} client #{session}"
end

helpers do
  def app_root
    "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
  end
end

get '/' do
  @title = "sensors"
  haml :index
end

get '/:source.css' do
  scss params[:source].to_sym
end
