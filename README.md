GoogleTTSPlugin
==========================
this gem overrides `adhearsion#say` and use google tts to speak( [try](http://translate.google.com/translate_tts?tl=en&q=this%20is%20a%20sample%20tts%20audio%20from%20google%20tts.) ).

it can

- speak in many languages 
- change speech speed
- change speech volume
- seed sln files from CSV

``` ruby
# languages
{"Afrikaans"=>"af", "Albanian"=>"sq", "Amharic"=>"am", "Arabic"=>"ar", "Armenian"=>"hy", "Azerbaijani"=>"az", "Basque"=>"eu", "Belarusian"=>"be", "Bengali"=>"bn", "Bihari"=>"bh", "Bosnian"=>"bs", "Breton"=>"br", "Bulgarian"=>"bg", "Cambodian"=>"km", "Catalan"=>"ca", "Chinese (Simplified)"=>"zh-CN", "Chinese (Traditional)"=>"zh-TW", "Corsican"=>"co", "Croatian"=>"hr", "Czech"=>"cs", "Danish"=>"da", "Dutch"=>"nl", "English"=>"en", "Esperanto"=>"eo", "Estonian"=>"et", "Faroese"=>"fo", "Filipino"=>"tl", "Finnish"=>"fi", "French"=>"fr", "Frisian"=>"fy", "Galician"=>"gl", "Georgian"=>"ka", "German"=>"de", "Greek"=>"el", "Guarani"=>"gn", "Gujarati"=>"gu", "Hacker"=>"xx-hacker", "Hausa"=>"ha", "Hebrew"=>"iw", "Hindi"=>"hi", "Hungarian"=>"hu", "Icelandic"=>"is", "Indonesian"=>"id", "Interlingua"=>"ia", "Irish"=>"ga", "Italian"=>"it", "Japanese"=>"ja", "Javanese"=>"jw", "Kannada"=>"kn", "Kazakh"=>"kk", "Kinyarwanda"=>"rw", "Kirundi"=>"rn", "Klingon"=>"xx-klingon", "Korean"=>"ko", "Kurdish"=>"ku", "Kyrgyz"=>"ky", "Laothian"=>"lo", "Latin"=>"la", "Latvian"=>"lv", "Lingala"=>"ln", "Lithuanian"=>"lt", "Macedonian"=>"mk", "Malagasy"=>"mg", "Malay"=>"ms", "Malayalam"=>"ml", "Maltese"=>"mt", "Maori"=>"mi", "Marathi"=>"mr", "Moldavian"=>"mo", "Mongolian"=>"mn", "Montenegrin"=>"sr-ME", "Nepali"=>"ne", "Norwegian"=>"no", "Norwegian (Nynorsk)"=>"nn", "Occitan"=>"oc", "Oriya"=>"or", "Oromo"=>"om", "Pashto"=>"ps", "Persian"=>"fa", "Pirate"=>"xx-pirate", "Polish"=>"pl", "Portuguese (Brazil)"=>"pt-BR", "Portuguese (Portugal)"=>"pt-PT", "Portuguese"=>"pt", "Punjabi"=>"pa", "Quechua"=>"qu", "Romanian"=>"ro", "Romansh"=>"rm", "Russian"=>"ru", "Scots Gaelic"=>"gd", "Serbian"=>"sr", "Serbo-Croatian"=>"sh", "Sesotho"=>"st", "Shona"=>"sn", "Sindhi"=>"sd", "Sinhalese"=>"si", "Slovak"=>"sk", "Slovenian"=>"sl", "Somali"=>"so", "Spanish"=>"es", "Sundanese"=>"su", "Swahili"=>"sw", "Swedish"=>"sv", "Tajik"=>"tg", "Tamil"=>"ta", "Tatar"=>"tt", "Telugu"=>"te", "Thai"=>"th", "Tigrinya"=>"ti", "Tonga"=>"to", "Turkish"=>"tr", "Turkmen"=>"tk", "Twi"=>"tw", "Uighur"=>"ug", "Ukrainian"=>"uk", "Urdu"=>"ur", "Uzbek"=>"uz", "Vietnamese"=>"vi", "Welsh"=>"cy", "Xhosa"=>"xh", "Yiddish"=>"yi", "Yoruba"=>"yo", "Zulu"=>"zu"}
```

## Installation

Make sure you have `sox` installed (+ `mpg123` on centos - CentOS Prerequisite http://ofps.oreilly.com/titles/9780596517342/asterisk-Initial.html)

    # centos
    sudo yum install mpg123 # CentOS Prerequisite http://ofps.oreilly.com/titles/9780596517342/asterisk-Initial.html
    sudo yum install sox

    # ubuntu
    sudo apt-get install sox libsox-fmt-all

    # osx
    brew install sox

Add this line to your adhearsion application's Gemfile:

    gem 'google_tts_plugin', git: "https://github.com/github0013/google_tts_plugin.git"

And then execute:

    bundle

## Usage

``` ruby
# config/adhearsion.rb
Adhearsion.config.google_tts_plugin do |config|
  config.save_to = "/where/you/wanna/save/speech/files" # make sure you have permissions write
  config.language = "ja" 
  config.speed = "120%"
  config.volume = "130%"
  #config.google_tts = "change here if google changes tts uri" 
  config.mpg123_path = "/usr/bin/mpg123" # change it to your path or nil if not installed (but required on centos)
  config.sox_path = "/usr/bin/sox"       # change it to your path
end


# your CallController
class SimonGame < Adhearsion::CallController
  # make sure you include this line
  include GoogleTTSPlugin::ControllerMethods

  def run
    say "世界の皆さんこんにちわ" # "ja" set at config
    say "hello world!", language: "en" # can change at runtime
    say "hello world!", language: "en", speed: "200%", volume: "200%"
  end
end
```

# tasks

`rake google_tts_plugin:seed[csv_file]`
Downloads .mp3 from google, convert and save in .sln.
Since **say** in your **CallController** will do this at run time, its initial call can delay and you can prevent it with this task.

``` csv
text,language,speed,volume
hello world,,,
世界の皆さんこんにちわ,ja,50,80
```
*`text` is required  
Plugin default values will be applied for blanks.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
