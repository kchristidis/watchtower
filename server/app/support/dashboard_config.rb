class DashboardConfig
  attr_accessor :plots, :refresh_rate, :time_from, :time_to, :limit, :custom_signals

  def initialize
    self.plots = []
    self.custom_signals = []
  end

  def self.parse(json)
    config = DashboardConfig.new
    json = JSON.parse(json || config.to_json)
    config.plots = json['plots']
    config.refresh_rate = json['refresh_rate']
    config.time_from = json['time_from']
    config.time_to = json['time_to']
    config.limit = json['limit']
    config.custom_signals = json['custom_signals']
    config
  end
end
