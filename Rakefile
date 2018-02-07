task :synchronize_tweets do
	require "./app.rb"
	init_twitter
	tweets = Tweet.all
	tweets.each do |tweet|
		t = @client.status(tweet.tweet_id).to_h
    tweet.retweet_count = t[:retweet_count]
    tweet.favorite_count = t[:favorite_count]
    tweet.save
	end	
end

task :get_new_tweets do
	require "./app.rb"
	init_twitter
	twittermens = Twittermen.all
	twittermens.each do |twittermen|
    get_new_tweets(twittermen)
	end	
end

def init_twitter
	require 'twitter'
  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "kr7WFFg1KFH2VEIucUmQkmqka"
    config.consumer_secret     = "hzA8YuZVRvePb77gmtW3A0AvCczRdXbTc85ohXmYR32zmWN7Zn"
    config.access_token        = "960251622663294978-7ijfAEr2FJEDRvQAl7KNOCootM8Iqp5"
    config.access_token_secret = "8bH1vrA16L0Ljjd6u96eJPkjeO9TeMMq7faVzauJFr5Dh"
  end
end

def get_new_tweets(twittermen)
  twitter_user = @client.user(twittermen.twitter_id)
  last_id = Tweet.all(twittermen: twittermen, order: [:tweet_time.desc]).first.tweet_id
  tweets = @client.user_timeline(twittermen.twitter_id, since_id: last_id, tweet_mode: 'extended')
  add_new_tweets(twittermen, tweets)
end
