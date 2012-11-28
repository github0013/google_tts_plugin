# encoding: utf-8
require 'spec_helper'

module GoogleTTSPlugin
  describe Plugin do
    describe Plugin::CsvToSln do
      let(:config){ mock("config").as_null_object }
      let(:csv_file) do
        Tempfile.open("test_csv") do |t|
          t.puts "text,language,speed,volume"
          t.puts "all defaults,,,"
          t.puts "language changed,ja,,"
          t.puts "speed changed,,100%,"
          t.puts "volume changed,,,100%"
          t.puts "" # empty row
          t.puts "" # empty row
          t.path
        end
      end
      subject{ ControllerMethods::TTSToSln }
      before(:each) do
        config.stub(:language).and_return "en"
        config.stub(:speed).and_return "120%"
        config.stub(:volume).and_return "150%"
        
        subject.stub(:new).and_return mock("TTSToSln").as_null_object
      end
      
      specify do
        subject.should_receive(:new).ordered.with(q: "all defaults", tl: "en", speed: "120%", volume: "150%")
        subject.should_receive(:new).ordered.with(q: "language changed", tl: "ja", speed: "120%", volume: "150%")
        subject.should_receive(:new).ordered.with(q: "speed changed", tl: "en", speed: "100%", volume: "150%")
        subject.should_receive(:new).ordered.with(q: "volume changed", tl: "en", speed: "120%", volume: "100%")
        
        Plugin::CsvToSln.load(config, csv_file)
      end
    end
  end
  
end
