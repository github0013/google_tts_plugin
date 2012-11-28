# encoding: utf-8
module GoogleTTSPlugin
  class Plugin < Adhearsion::Plugin

    config :google_tts_plugin do
      save_to  "/var/lib/asterisk/sounds/google_tts", desc: "mp3 will be converted to .sln and saved under this folder"
      language "en",  desc: "text to speech language"
      speed  "100%",  desc: "speech speed (integer, ex: 150% is 1.5times faster speech)"
      volume "100%",  desc: "speech volume (integer, ex: 200% is twice as loud)"
      google_tts "http://translate.google.com/translate_tts", desc: "google tts uri"
      mpg123_path "", desc: "CentOS Prerequisite: Since CentOS does not have MP3 capability installed with sox, you will have to install mpg123 before you can convert MP3 files for use with Asterisk. (http://ofps.oreilly.com/titles/9780596517342/asterisk-Initial.html)"
      sox_path "", desc: "please make sure you have sox installed"
    end
   
    class CsvToSln
      require "csv"
      
      class << self
        def load(config, csv_file)
          CSV.open(csv_file, "r:utf-8", headers: true, header_converters: :symbol).each do |row|
            next unless row[:text].to_s.strip.present?
            
            this_params = {
              language: config.language,
              speed:    config.speed,
              volume:   config.volume
            }
            
            this_params.keys.each do |key|
              this_params.merge!(key => row[key]) if row[key].to_s.strip.present?
            end
            
            this_params[:q] = row[:text]
            this_params[:tl] = this_params.delete(:language)
            ControllerMethods::TTSToSln.new(this_params).convert            
          end
          
        end
      end
    end
    
    tasks do
      namespace :google_tts_plugin do
        desc "loads a csv file from TTS_SEED_CSV env variable"
        task :seed, [:csv_file] => [:environment] do |task, args|
          CsvToSln.load(Adhearsion.config.google_tts_plugin, args.csv_file)
        end
      end
    end
  end
end
