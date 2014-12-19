module Botolo
  module Bot
    class Behaviour
      def initialize(options={})
      end

      def say_hello
        puts "hello"
      end

      def say_foo
        puts "foo"
      end

      def tweet_hello
        return "" if $twitter_api.nil?
        $twitter_api.tweet("hello")
      end
    end
  end
end

