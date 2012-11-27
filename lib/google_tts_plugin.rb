#GoogleTTSPlugin = Module.new
require "google_tts_plugin/version"
require "google_tts_plugin/plugin"
require "google_tts_plugin/controller_methods"
require "tempfile"
require "pathname"
require "fileutils"
require "digest/md5"
require "mechanize"
