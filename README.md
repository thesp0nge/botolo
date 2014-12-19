# Botolo

Botolo is an engine for bots written in ruby. With botolo you must take care
only about writing actions your bot must implement and then the engine will
execute them for you.

## Installation

Add this line to your application's Gemfile:

    gem 'botolo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install botolo

## Usage

For creating a great bot you have to describe in a YAML configuration file the
Bot behaviour and in a separate ruby class you must implement the methods your
bot must carry on.

Let's see how to create a very dummy bot saying _foo_ every 3 seconds and
saying _hello_ every 5 seconds. 

You have to write a config.yaml file containing the action schedule and some
very basic information about your bot.

``` 
verbose: true

bot:
  name: dummy-bot
  version: 1.0
  email: paolo@codesake.com
  # This overrides any behaviour file passed as argument
  behaviour: dummy-bot.rb
  logfile: dummy-bot.log

twitter:
  enabled: no
task:
  - { schedule: every 5 s, action: say_hello }
  - { schedule: every 3 s, action: say_foo }
``` 

Botolo expects to find in the current directory a file named dummy-bot.rb
implementing the two methods (say\_hello and say\_foo) it has to run based upon
this schedule. 
There is a **big** constraint: your ruby file must be a Botolo::Bot::Behaviour
class. It must also implement an initialize method with an Hash parameter
engine will use to pass options to the bot.

It will be used in the future to implement some form of communication between
the main process and threads, useful to provide a centralized console about
what's going on on your bot.

Let's see our dummy bot behaviour:

``` 
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
    end
  end
end
``` 

It's easy, isn't it!?! 

Now, all you have to do is running the botolo command specifying the config
file as parameter. Remember to put the behaviour class in the same directory of
your YAML file.

``` 
$ botolo config.yaml
botolo:9: warning: already initialized constant OpenSSL::SSL::VERIFY_PEER 
[*] dummy-bot v1.0 is starting up at 08:31:31
08:31:31: 2 tasks loaded
08:31:31: using ./dummy-bot.rb as bot behaviour
08:31:31: dummy-bot is online
08:31:31: entering main loop
08:31:31: hello
08:31:31: foo
08:31:34: foo
08:31:36: hello
08:31:37: foo
08:31:40: foo
08:31:41: hello
08:31:43: foo
^C08:31:46: shutting down threads
08:31:46: pid #<Thread:0x007fa731022e18> killed
08:31:46: pid #<Thread:0x007fa731022cd8> killed
[*] bot is shutting down at 08:31:46
``` 

Custom written behaviour can use the global variable $logger to use botolo logging
facilities and having the stdout/stderr prints more consistent.

The same ruby class can have some social integration adding twitter support in
its behaviour file.

Since botolo version 0.50, more twitter accounts are supported and
Botolo::API::Twitter are introduced to provide basic services to your bots.

```
verbose: true

bot:
  name: dummy-bot
  version: 1.0
  email: paolo@codesake.com
  behaviour: dummy-bot.rb

twitter:
  enabled: yes
  accounts:
    - { name: first, consumer_key: "AAAAAAAAAAAAAAAAAAAAAAAAA", consumer_secret: "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", oauth_token: "999999999-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC", oauth_token_secret: "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"}
    - { name: second, consumer_key: "AAAAAAAAAAAAAAAAAAAAAAAAA", consumer_secret: "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", oauth_token: "999999999-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC", oauth_token_secret: "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"}
    - { name: third, consumer_key: "AAAAAAAAAAAAAAAAAAAAAAAAA", consumer_secret: "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", oauth_token: "999999999-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC", oauth_token_secret: "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"}

task:
  - { schedule: every 5 s, action: say_hello }
  - { schedule: every 3 s, action: say_foo }
  - { schedule: every 1 h, action: tweet_hello }
```

The tweet\_hello routine is very simple:

```
def tweet_hello
  return "" if $twitter_api.nil?
  $twitter_api.tweet("hello")
end
```

The ```$twitter_api``` ojeect is something provided by the engine, so it's very
easy for bot writers.

## Missing features

Other social network integration, mainly facebook.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
