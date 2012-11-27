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
    
  end
end
