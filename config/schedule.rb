# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "cron_log.log"
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']

every 6.hours do
#   command "/usr/bin/some_great_command"
#  runner "Tweet.aaa"
    #runner "bundle exec bbb"

   rake "synchronize_tweets"
   rake "get_new_tweets"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
