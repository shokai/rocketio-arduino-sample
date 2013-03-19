RocketIO + ArduinoFirmata
=========================
display real-time sensor values on WebBrowser

* https://github.com/shokai/rocketio-arduino-sample


Requirements
------------
* Ruby 1.8.7+
* [Sinatra RocketIO](https://github.com/shokai/sinatra-rocketio)
* [ArduinoFirmata on Ruby](https://github.com/shokai/arduino_firmata)


Install Dependencies
--------------------

    % gem install bundler
    % bundle install

Run
---

    % rackup config.ru -p 5000

open http://localhost:5000


config WebSocket port and Arduino

    % ARDUINO=/dev/tty.usb-devicename WS_PORT=8080 rackup config.ru -p 5000
