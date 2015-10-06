# encoding: utf-8
module GoogleTTSPlugin
  module ControllerMethods
    
    class TTSToSln
      attr_reader :params

      def initialize(options = {})
        @params = options
      end
      
      class << self
        def config
          Adhearsion.config[:google_tts_plugin]
        end
      end
      
      def sln_file
        Pathname(config.save_to).join sln_md5_filename
      end
      
      def sln_file_path_without_extension
        filename, extension = sln_file.basename.to_s.split "."
        sln_file.dirname.join filename 
      end

      def convert
        return sln_file_path_without_extension if has_sln?
        
        volume = params[:volume].to_i / 100.0
        
        volume_file = :not_defined
        target_file.basename.to_s.tap do |basename_to_s|
          basename, extension = basename_to_s.split "."
          volume_file = target_file.dirname.join("#{basename}-v#{volume}.#{extension}").to_s
        end
        
        #create volume file
        Kernel.system "#{config.sox_path} --volume #{volume} #{target_file} #{volume_file}"
        #move to target_file(tempfile). this will ensure the file will be deleted by GC
        FileUtils.mv volume_file, target_file.to_s
        
        sox_options = Hash[*%w[
            --type raw
            --encoding signed-integer
            --bits 16
            --channels 1
            --rate 8k
          ]].
          collect{|key,value| "#{key} #{value}"}.join " "
        
        #create .sln file
        FileUtils.mkdir_p sln_file.dirname.to_s
        Kernel.system "#{config.sox_path} #{target_file} #{sox_options} #{sln_file} tempo #{params[:speed].to_i / 100.0}"
        
        sln_file_path_without_extension
      end
      
      
      private
        def config
          self.class.config
        end

        def sln_md5_filename
          "#{Digest::MD5.hexdigest params.inspect}.sln"
        end
        
        def has_sln?
          File.exist?(sln_file)
        end

        def wav_file
          mp3_file.dirname.join("#{Pathname(mp3_file).basename(".mp3")}.wav").tap do |wav_file_path|
            Kernel.system "#{config.mpg123_path} -w #{wav_file_path} #{mp3_file}"
          end
        end

        def mp3_file
          Pathname(
            Tempfile.open(%w[google_tts .mp3]) do |t|
              mp3 = Mechanize.new{|agent| agent.user_agent_alias = "Mac Safari" }.
                              get("#{config.google_tts}", params).body
              t.write mp3
              t.path
            end
          )
        end

        def mpg123?
          config.mpg123_path.present?
        end
        
        def target_file
          @target_file ||= if mpg123?
            mp3_file
            wav_file
          else
            mp3_file
          end
        end
    end
    
    def say(text, options = {})
      play tts_sound_file_path(text, options)
    end
    alias :speak :say
    
    def tts_sound_file_path(text, options = {})
      params = {}
      params[:q] = text.to_s
      params[:tl] = options[:language] || TTSToSln.config.language
      params[:speed] = options[:speed] || TTSToSln.config.speed.to_i
      params[:volume] = options[:volume] || TTSToSln.config.volume.to_i
      params[:client] = opetions[:client] || TTSToSln.config.client
      
      TTSToSln.new(params).convert.to_s
    end

  end
end
