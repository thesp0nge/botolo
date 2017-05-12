require 'rss'

module Botolo
  module API
    class Blog

      def initialize(options={})
        @url = options[:url]
        @tweet = options[:tweet_api]
      end

      def refresh_rss
        rss = nil

        open("#{@url}/feed.xml") do |http|
          response = http.read
          rss = RSS::Parser.parse(response, false)
        end
        @feed = []
        rss.items.each_with_index do |item, i|
          @feed << {:title=>item.title.content, :link=>item.link.href}
        end
        $logger.info "#{@feed.size} elements loaded from feed"
      end

      def tweet_random_posts(limit = 3, hashtags="")
        return nil if @feed.nil? || @feed.size == 0
        (0..limit-1).each do |l|
          post = @feed[SecureRandom.random_number(@feed.size)]
          m = "\"#{post[:title]}\" (#{post[:link]}) #{hashtags}"
          $logger.debug "#{m} - #{m.length}"
          begin
            @tweet.tweet(m)
            $logger.debug "tweet sent!"
          rescue => e
            $logger.err("error tweeting #{m}: #{e.message}")
          end
          sleep(10)

        end
      end

      def promote_latest(hashtags="")
        return nil if @feed.nil? || @feed.size == 0
        post = @feed[0]
        m = "\"#{post[:title]}\" (#{post[:link]}) #blog #sicurezza #informatica."
        $logger.debug "#{m} - #{m.length}"
        begin
          @tweet.tweet(m)
        rescue => e
          $logger.err("error tweeting #{m}: #{e.message}")
        end
      end

    end
  end
end
