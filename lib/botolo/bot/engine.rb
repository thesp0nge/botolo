require 'twitter'
require 'yaml'

module Botolo
  module Bot
    class Engine

      def initialize(options={})
        @start_time = Time.now
        @online = false
        @config = read_conf(options[:config])
        authenticate if @config['twitter']['enabled']

        @tasks = @config['task']
        @task_pids = []

        behaviour = File.join(".", @config['bot']['behaviour']) unless @config['bot']['behaviour'].nil? 

        $logger.helo "#{name} v#{version} is starting up"
        
        $logger.log "#{@tasks.size} tasks loaded"

        begin
          load behaviour
          $logger.log "using #{behaviour} as bot behaviour"
          @behaviour = Botolo::Bot::Behaviour.new(@config)
        rescue => e
          $logger.err(e.message)
          require 'botolo/bot/behaviour'
          $logger.log "reverting to default dummy behaviour"
          @behaviour = Botolo::Bot::Behaviour.new(@config)
        end


      end

      def calc_sleep_time(task)
        
        s = /every (\d) (s|m|h|d|w|y)/.match task

        return 300 if s.nil? # safe fallback is 5 minutes sleeping

        return s[1].to_i                         if s[2] == 's'
        return s[1].to_i * 60                    if s[2] == 'm'
        return s[1].to_i * 60 * 60               if s[2] == 'h'
        return s[1].to_i * 60 * 60 * 24          if s[2] == 'd'
        return s[1].to_i * 60 * 60 * 24 * 7      if s[2] == 'w'
        return s[1].to_i * 60 * 60 * 24 * 7 * 52 if s[2] == 'y'

      end

      def run
        $logger.log "entering main loop"
        @tasks.each do |task|
          @task_pids << Thread.start do
            start_task(task['action'], task['schedule'])
          end
        end

      end

      def infinite_loop
        while true

        end
      end

      def start_task(name, sleep)
        while true
          begin 
            @behaviour.send(name.to_sym) if @behaviour.respond_to? name.to_sym
          rescue => e
            $logger.err "#{name} failed (#{e.message})"
          end
          sleep calc_sleep_time(sleep)
        end

      end

      def stop
        $logger.log "shutting down threads"
        @task_pids.each do |pid|
          Thread.kill(pid)
          sleep 0.1
          $logger.log "pid #{pid} killed" if ! pid.alive? 
          $logger.err "pid #{pid} not killed" if pid.alive? 
        end

        true
      end

      
      def authenticate
        begin
          Twitter.configure do |config|
            config.consumer_key = @config['twitter']['consumer_key']
            config.consumer_secret = @config['twitter']['consumer_secret']
            config.oauth_token = @config['twitter']['oauth_token']
            config.oauth_token_secret = @config['twitter']['oauth_token_secret']
          end
          @online = true
        rescue Exception => e
          $logger.err e.message
        end
      end

      def online?
        @online
      end

      def name
        return @config['bot']['name']
      end
      def version
        return @config['bot']['version']
      end

      def uptime
        Time.now - @start_time
      end

      def read_conf(filename=nil)
        return {} if filename.nil? or ! File.exist?(filename) 
        return YAML.load_file(filename)
      end

    end
  end
end
