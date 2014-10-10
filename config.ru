require 'sinatra/base'
require_relative 'bots'

class KeepAlive < Sinatra::Base
  get '/' do
    url = 'https://twitter.com/enbybooks'
    "You probably want <a href='#{url}'>#{url}</a>."
  end
end

Thread.new do
  EM.run do
   Ebooks::Bot.all.each do |bot|
      bot.start
    end
  end
end

run KeepAlive
