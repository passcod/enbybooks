class EnbyBot < Ebooks::Bot
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # OAuth details can be fetched with https://github.com/marcel/twurl
    self.consumer_key = ENV['TWITTER_KEY']
    self.consumer_secret = ENV['TWITTER_SECRET']
    @model = Ebooks::Model.load('model/enbybooks.model')
  end

  def on_startup
    scheduler.every '1h' do
      # Tweet something every 24 hours
      # See https://github.com/jmettraux/rufus-scheduler
      # bot.tweet("hi")
      tweet @model.make_statement(140)
    end
  end

  def on_message(dm)
    # Reply to a DM
    # bot.reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    follow(user[:screen_name])
  end

  def on_mention(tweet)
    # Reply to a mention
    reply tweet, meta(tweet).reply_prefix + @model.make_response(tweet.text, 139 - meta(tweet).reply_prefix.length)
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # bot.reply(tweet, meta[:reply_prefix] + "nice tweet")
  end
end

EnbyBot.new('enbybooks') do |bot|
  bot.access_token = ENV['OAUTH_TOKEN']
  bot.access_token_secret = ENV['OAUTH_SECRET']
end
