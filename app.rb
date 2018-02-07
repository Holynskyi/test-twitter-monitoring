require 'rubygems'
require 'bundler'
require 'sinatra/base'
require 'rack-flash'
require 'sinatra/redirect_with_flash'
require "dm-core"
require 'dm-sqlite-adapter'
require "dm-migrations"
require "dm-validations"
require "digest/sha1"
require "sinatra-authentication"
require "haml"
require 'twitter'
require "pry"
require "pry-nav"

Bundler.require
use Rack::Session::Cookie, secret: "hg46j3g5479834rhf48fo4i28hy7d"
use Rack::Flash, accessorize: [:error, :success]
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/twitter_monitoring.db")


class Twittermen
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :twitter_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  belongs_to :dm_user
  has n, :tweets

  validates_uniqueness_of :twitter_id, :scope => :dm_user_id
end

class DmUser
  has n, :twittermens
end

class Tweet
  include DataMapper::Resource
  property :id, Serial
  property :body, Text
  #property :url, String
  property :tweet_id, Integer
  property :retweet_count, Integer
  property :favorite_count, Integer
  property :tweet_time, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  belongs_to :twittermen

end

get '/' do  
	haml :home
end

get '/find_twitter_user' do
  begin  
	login_required
  init_twitter_client
  @twitter_user = @client.user(params["name"])
	haml :find_twitter_user
  rescue  
    flash[:error] = "Twitter user not found"
    redirect '/'
  end
end

post '/twittermens' do
  login_required
  init_twitter_client
  twitter_user = @client.user(params["twittermen_short_name"])

  twittermen = Twittermen.new
  twittermen.twitter_id = twitter_user.id
  twittermen.name = twitter_user.name
  twittermen.created_at = Time.now
  twittermen.updated_at = Time.now
  twittermen.dm_user = current_user

  if twittermen.save
    tweets = @client.user_timeline(twittermen.twitter_id, tweet_mode: 'extended')
    add_new_tweets(twittermen, tweets)
    redirect '/twittermens'
  else
    flash[:error] = twittermen.errors.full_messages
    redirect '/'
  end

end

get '/twittermens' do
  login_required
  #@twittermens = current_user.db_instance.twittermens
  @twittermens = Twittermen.all(:dm_user_id => current_user.id)   
  haml :twittermens_index
end

delete '/twittermens/:id' do
  twittermen = Twittermen.get(params[:id])
  twittermen.destroy
end

get '/tweets' do
  login_required
  @tweets = Tweet.all(twittermen: Twittermen.all(dm_user_id: current_user.id), order: [:tweet_time.desc])
  haml :tweets_index
end  

helpers do
    include Rack::Utils
end

def init_twitter_client
  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "kr7WFFg1KFH2VEIucUmQkmqka"
    config.consumer_secret     = "hzA8YuZVRvePb77gmtW3A0AvCczRdXbTc85ohXmYR32zmWN7Zn"
    config.access_token        = "960251622663294978-7ijfAEr2FJEDRvQAl7KNOCootM8Iqp5"
    config.access_token_secret = "8bH1vrA16L0Ljjd6u96eJPkjeO9TeMMq7faVzauJFr5Dh"
  end
end

def add_new_tweets(twittermen, tweets)
  tweets.each do |tweet|
    t = tweet.to_h
    new_tweet = Tweet.new
    new_tweet.body = t[:full_text]
    new_tweet.tweet_id = t[:id]
    new_tweet.retweet_count = t[:retweet_count]
    new_tweet.favorite_count = t[:favorite_count]
    new_tweet.tweet_time = DateTime.parse t[:created_at]
    new_tweet.created_at = Time.now
    new_tweet.updated_at = Time.now
    new_tweet.twittermen_id = twittermen.id
    new_tweet.save
  end

end