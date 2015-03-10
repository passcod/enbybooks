require 'after_the_deadline'

class EnbyBot < Ebooks::Bot
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # OAuth details can be fetched with https://github.com/marcel/twurl
    self.consumer_key = ENV['TWITTER_KEY']
    self.consumer_secret = ENV['TWITTER_SECRET']
    @model = Ebooks::Model.load('model/enbybooks.model')
    AfterTheDeadline(nil, ['Passive voice'])
  end

  def on_startup
    t = self.twitter
    u = self.username
    scheduler.every '5m' do
      last_tweet = t.user_timeline(u,
        exclude_replies: true, include_rts: false).first
      if !last_tweet.nil?
        time_now = Time.now
        time_then = last_tweet.created_at
        hours_ago = (time_now - time_then) / (60 * 60)
        return if hours_ago < 1 # don't tweet
      end

      # only tweet things that look sufficiently correct
      round = 0
      phrase = ''
      loop do
        phrase = @model.make_statement(140)
        round += 1
        break if round > 5
        break if AfterTheDeadline.check(phrase.gsub(' i ', ' I ')).length < 2
      end

      tweet phrase
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
