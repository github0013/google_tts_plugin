# encoding: utf-8
require 'spec_helper'

module GoogleTTSPlugin
  describe ControllerMethods do
    before(:each) do
      stub_request(:any, %r|translate.google.com/translate_tts|).
        to_return body: File.read(SPEC_ROOT.join "mp3/sample.mp3") 
      Kernel.stub(:system)
    end
    
    describe ControllerMethods::GoogleTTSToSln do
      let(:params) do
        {
          q: "google tts!",
          tl: "en",
          speed: 100,
          volume: 100
        }
      end
      subject(:google_tts_to_sln){ ControllerMethods::GoogleTTSToSln.new params }
      before(:each) do
        Adhearsion.config[:google_tts_plugin].stub(:mpg123_path).and_return "/usr/bin/mpg123"
        Adhearsion.config[:google_tts_plugin].stub(:sox_path).and_return "/usr/bin/sox"
      end

      its(:sln_md5_filename){ should == "87aa60d03a768add559e9f7a90539301.sln" }
      its(:sln_file){ should == Pathname("/var/lib/asterisk/sounds/google_tts/87aa60d03a768add559e9f7a90539301.sln") }
      
      context '#has_sln?' do
        context "when sln doesn't exist" do 
          subject{ google_tts_to_sln.send :has_sln? }
          it{ should be_false }
        end
        
        context "when sln exists" do
          before(:each) do
            subject.stub(:sln_file).and_return Tempfile.open(["test", ".sln"]){|f| f.path}
            subject{ google_tts_to_sln.send :has_sln? }
          end

          it{ should be_true }
        end
      end
      
      context '#mp3_file' do
        subject{ google_tts_to_sln.send(:mp3_file).to_s }
        it{ should =~ /.mp3$/ }
      end
      
      context '#wav_file' do
        subject{ google_tts_to_sln.send(:wav_file).to_s }
        
        it{ should =~ /.wav$/ }
      end

      context "downloading mp3" do
        context '#target_file' do
          context "when mpg123 is set" do
            let(:test_mp3_file){ "/tmp/test.mp3" }
            let(:test_wav_file){ "/tmp/test.wav" }
            
            before(:each) do 
              subject.stub(:mpg123?).and_return true
              subject.stub(:mp3_file).and_return Pathname(test_mp3_file)
            end
            
            specify do 
              subject.should_receive(:wav_file)
              subject.send(:target_file)
            end
            
            specify do
              Kernel.should_receive(:system).with("/usr/bin/mpg123 -w #{test_wav_file} #{test_mp3_file}")
              subject.send(:target_file) 
            end
            
            specify do
              subject.send(:target_file).to_s.should match /wav$/
            end
          end
          
          context "when mpg123 is NOT set" do
            before(:each) do
              subject.stub(:mpg123?).and_return false
            end
            
            specify do 
              subject.should_not_receive(:wav_file)
              subject.send(:target_file)
            end
            
            specify do 
              subject.send(:target_file).to_s.should match /mp3$/
            end
          end
        end
      end
      
      context '#tts_to_sln' do
        
        context "has sln file" do
          before(:each) do
            test_sln_file = Tempfile.open(["test", ".sln"]){|f| f.path}
            subject.stub(:sln_file).and_return Pathname(test_sln_file)
          end
          
          its(:tts_to_sln){ should == google_tts_to_sln.sln_file_path_without_extension }
        end
        
        context "does NOT have sln file" do
          let(:test_target_file){ "/tmp/test.mp3" }
          let(:test_volume_file){ "/tmp/test-v1.0.mp3" }
          let(:sox_options){ "--type raw --encoding signed-integer --bits 16 --channels 1 --rate 8k" }
          let(:test_sln_file){ "/tmp/test.sln" }
          before(:each) do
            subject.stub(:target_file).and_return Pathname(test_target_file)
            subject.stub(:sln_file).and_return Pathname(test_sln_file)
            FileUtils.stub(:mkdir_p)
            FileUtils.stub(:mv)
          end

          specify do
            FileUtils.should_receive(:mkdir_p)
            subject.tts_to_sln
          end

          specify do
            FileUtils.should_receive(:mv).with("#{test_volume_file}", "#{test_target_file}")
            subject.tts_to_sln
          end

          specify do 
            Kernel.should_receive(:system).once.ordered.with("/usr/bin/sox --volume 1.0 #{test_target_file} #{test_volume_file}")
            Kernel.should_receive(:system).once.ordered.with("/usr/bin/sox #{test_target_file} #{sox_options} #{test_sln_file} tempo 1.0")
            subject.tts_to_sln
          end
          
          its(:tts_to_sln){ subject.should == google_tts_to_sln.sln_file_path_without_extension }
          
          context "speed control" do
            subject{ ControllerMethods::GoogleTTSToSln.new params.merge({speed: 57}) }
            
            specify do
              Kernel.should_receive(:system).once.ordered
              Kernel.should_receive(:system).once.ordered.with("/usr/bin/sox #{test_target_file} #{sox_options} #{test_sln_file} tempo 0.57")
              subject.tts_to_sln
            end
          end
          
          context "volume control" do
            let(:test_volume_file){ "/tmp/test-v1.5.mp3" }
            subject{ ControllerMethods::GoogleTTSToSln.new params.merge({volume: 150}) }
            
            specify do
              Kernel.should_receive(:system).once.ordered.with("/usr/bin/sox --volume 1.5 #{test_target_file} #{test_volume_file}")
              Kernel.should_receive(:system).once.ordered
              subject.tts_to_sln
            end
          end
        end
      end
    end
    
    describe "mixed in to a CallController" do
      class TestController < Adhearsion::CallController
        include GoogleTTSPlugin::ControllerMethods
      end

      let(:mock_call) { mock 'Call' }
      subject(:controller) do
        TestController.new mock_call
      end

      it{ should respond_to :say }
      
      describe '#say' do
        let(:google_tts){ mock("GoogleTTSToSln").as_null_object }
        before(:each) do
          subject.stub :play
        end
        
        specify do
          ControllerMethods::GoogleTTSToSln.should_receive(:new).and_return google_tts
          google_tts.should_receive :tts_to_sln

          subject.say "test speech"
        end
        
        specify do
          ControllerMethods::GoogleTTSToSln.stub(:new).and_return google_tts
          subject.should_receive :play
          
          subject.say "test speech"
        end
      end
    end
  end
end
