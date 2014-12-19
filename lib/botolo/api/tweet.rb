require 'twitter'
require 'singleton'

module Botolo
  module API
    class Tweet

      # twitters is a twitter client array read from configuration file and
      # used to access the social network for a given account.
      attr_reader :twitters
      include Singleton

      def authenticate(config)
        @twitters = []
        config['accounts'].each do |account|
          a=Hash.new
          a[:name] = account['name']
          begin
            $logger.log "authenticating #{a[:name]}"
            a[:client] = Twitter::REST::Client.new do |config|
              config.consumer_key         = account['consumer_key']
              config.consumer_secret      = account['consumer_secret']

              config.access_token         = account['access_token']        unless account['access_token'].nil?
              config.access_token_secret  = account['access_token_secret'] unless account['access_token_secret'].nil?
            end
          rescue Exception => e
            $logger.err e.message
          end

        @twitters << a
      end

      @twitters
    end

    def tweet(name=nil, msg)
      return nil if msg.empty?
      @twitters.each do |t|
        t[:client].update(msg) if (name.nil? or (!name.nil? and name == t[:name]))
      end
      return msg
    end

    def retweet(name=nil, msg)
      return nil if msg.empty?
      @twitters.each do |t|
        t[:client].retweet(msg) if (name.nil? or (!name.nil? and name == t[:name]))
      end
      return msg
    end

    def find_and_retweet_topic(limit = 5, topic)
      list = []
      @twitters.each do |tt|
        list << tt[:client].search("#appsec").to_a
      end

      unless list.nil?
        (0..limit-1).each do |l|
          t = list[SecureRandom.random_number(list.count)]
          $logger.debug "retwitting #{t["from_user"]}: #{t["text"]}"
          begin
            @twitters.each do |t|
              t[:client].retweet(msg) if (name.nil? or (!name.nil? and name == t[:name]))
            end
          rescue => e
              $logger.err("error tweeting #{t["text"]}: #{e.message}")
            end
            sleep(15)
          end
        end
      end


    end
  end
end
