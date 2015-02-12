require 'twitter_ebooks'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

require 'yaml'

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  attr_accessor :model
  attr_accessor :interval
  @@config = YAML.load(File.open("./config.yml"))
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = @@config["consumer_key"]
    self.consumer_secret = @@config["consumer_secret"]

    # Users to block instead of interacting with
    self.blacklist = @@config["blacklist"]

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def markov_tweet
        @archive.sync
        @tweet_model = Ebooks::Model.consume('corpus/'+ self.model + '.json')
        tweet @tweet_model.make_statement
  end

  def on_startup
    @archive = Ebooks::Archive.new(self.model)
    self.markov_tweet
    scheduler.every self.interval do
      self.markov_tweet
    end
  end

  def on_message(dm)
    # Reply to a DM
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    # follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    # reply(tweet, "oh hullo")
    response_delay = rand(self.config["response_delay"].to_i)
    scheduler.in "#{response_delay}m" do
      reply(tweet, @tweet_model.make_response(tweet.text))
    end
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end

  def on_favorite(user, tweet)
    # Follow user who just favorited bot's tweet
    # follow(user.screen_name)
  end
end

# Make a MyBot and attach it to an account

config = YAML.load(File.open("./config.yml"))

for x in config["bots"]
  MyBot.new(x["name"]) do |bot|
    bot.access_token = x["access_token"]
    bot.access_token_secret = x["access_token_secret"]
    bot.model = x["model"]
    bot.interval = x["interval"]
  end
end
