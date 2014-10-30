#!/usr/bin/env ruby

require 'twitter_ebooks'
require 'typhoeus'

class Ebooks::Model
  def self.load_str(str)
    Marshal.load(str)
  end
end

# This is an example bot definition with event handlers commented out
# You can define as many of these as you like; they will run simultaneously

Ebooks::Bot.new("enbybooks") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV['TWITTER_KEY']
  bot.consumer_secret = ENV['TWITTER_SECRET']
  bot.oauth_token = ENV['OAUTH_TOKEN']
  bot.oauth_token_secret = ENV['OAUTH_SECRET']
  modr = Typhoeus.get(ENV['MODEL_URL'])
  model = Ebooks::Model.load_str(modr.body)

  bot.on_message do |dm|
    # Reply to a DM
    # bot.reply(dm, "secret secrets")
  end

  bot.on_follow do |user|
    # Follow a user back
    # bot.follow(user[:screen_name])
  end

  bot.on_mention do |tweet, meta|
    # Reply to a mention
    # bot.reply(tweet, meta[:reply_prefix] + "oh hullo")
    if Random.rand > 0.5
      bot.reply tweet, meta[:reply_prefix] + model.make_response(tweet[:text], 139 - meta[:reply_prefix].length)
    end
  end

  bot.on_timeline do |tweet, meta|
    # Reply to a tweet in the bot's timeline
    # bot.reply(tweet, meta[:reply_prefix] + "nice tweet")
  end

  bot.scheduler.every '1h' do
    # Tweet something every 24 hours
    # See https://github.com/jmettraux/rufus-scheduler
    # bot.tweet("hi")
    bot.tweet model.make_statement(140)
  end
end
