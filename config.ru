require './app.rb'
DataMapper.finalize.auto_upgrade!

run Sinatra::Application