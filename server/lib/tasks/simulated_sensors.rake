require 'rake'

desc "Simulate multiple sensor data collection"
namespace :simulated_sensors do
  @simulations = []

  task cli: :environment do
    print "Sensor id: "
    sensor = Sensor.find STDIN.gets.to_i

    begin_simulation sensor
  end

  def begin_simulation(sensor)
    x=1
    cnt = 0
    while cnt < 100
      x = 100 * rand(10) * (Math.sin(2 * Math::PI * cnt / rand(90..100).to_f) + 1)
      puts DataPoint.create(
        data: x,
        sensor_id: sensor.id,
        timestamp: DateTime.now - (30 * cnt).minutes,
      ).data
      cnt += 1
    end
  end

  def list
    puts @simulations.inspect
  end
end

task simulated_sensors: 'simulated_sensors:cli'
