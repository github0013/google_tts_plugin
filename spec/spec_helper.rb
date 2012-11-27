require 'rubygems'
require 'spork'
require 'rspec'
require 'adhearsion'
require 'google_tts_plugin'
require 'webmock/rspec'
Dir[Pathname(__FILE__).dirname.join "support/**/*.rb"].each {|f| require f}
SPEC_ROOT = Pathname(__FILE__).dirname

Spork.prefork do
  RSpec.configure do |config|
    config.color_enabled = true
    config.tty = true
    
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    
    WebMock.disable_net_connect!
  end
  
end

Spork.each_run do

end
