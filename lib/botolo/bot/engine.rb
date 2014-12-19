require 'yaml'

module Botolo
  module Bot
    class Engine

      def initialize(options={})
        @start_time = Time.now
        @online = false
        @config = read_conf(options[:config])
        $twitter_api = nil

        behaviour_path = File.dirname(options[:config])

        if @config['twitter']['enabled']
          $twitter_api = Botolo::API::Tweet.instance
          $twitter_api.authenticate(@config['twitter']) 
          @online unless $twitter_api.twitters.empty?
        end

        @tasks = @config['task']
        @task_pids = []

        behaviour = File.join(behaviour_path, @config['bot']['behaviour']) unless @config['bot']['behaviour'].nil?

        $logger.helo name, version
        $logger.filename = File.join(".", logfile) unless logfile.nil?

        $logger.log "#{@tasks.size} tasks loaded"

        begin
          load behaviour
          $logger.log "using #{behaviour} as bot behaviour"
          @behaviour = Botolo::Bot::Behaviour.new(@config)
          @start_time = Time.now
        rescue => e
          $logger.err(e.message)
          require 'botolo/bot/behaviour'
          $logger.log "reverting to default dummy behaviour"
          @behaviour = Botolo::Bot::Behaviour.new(@config)
          @start_time = Time.now
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
        loop do
          sleep(3600) # => 1 h
          $logger.log " --- mark --- (bot: #{@behaviour.name}, uptime: #{uptime})"
        end
      end

      def uptime
        seconds_diff = (Time.now - @start_time).to_i.abs

        days = seconds_diff / 86400
        seconds_diff -= days * 86400

        hours = seconds_diff / 3600
        seconds_diff -= hours * 3600

        minutes = seconds_diff / 60

        "#{days.to_s} days, #{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}"
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
          sleep 0.5
          $logger.log "pid #{pid} killed" if ! pid.alive? 
          $logger.err "pid #{pid} not killed" if pid.alive? 
        end

        true
      end

      def online?
        @online
      end

      def logfile
        return @config['bot']['logfile']
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
