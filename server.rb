require "sinatra"
require "sinatra/activerecord"

#LOCAL
# ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: './database.sqlite3')
# set :database, {adapter: "sqlite3", database: "./database.sqlite3"}

#HEROKU
require "active_record"
ActiveRecord::Base.establish_connection(ENV["postgres://cmgccubjdpzqod:99d344e5c40a93b5fbe50724ebb40fc0d0a5bf7f65ad147c545d5077185aed6b@ec2-174-129-229-106.compute-1.amazonaws.com:5432/d3n6s0ulol1jq"])

enable :sessions

class User < ActiveRecord::Base
  attr_accessor :birthday
end

get '/' do
  if session[:user_id]
    redirect "/feed"
  else
    erb :home
  end
end

get '/signup' do
  if session[:user_id]
    redirect "/feed"
  else
    @user = User.new
    erb :signup
  end
end

post "/signup" do
  @user = User.new(params)
  if @user.save
    p "#{@user.first_name} was saved to the database"
    redirect "/thanks"
  end
end

get "/thanks" do
  erb :thanks
end

get '/login' do
  if session[:user_id]
    redirect "/feed"
  else
    erb :login
  end
end

post "/login" do
  given_password = params['password']
  user = User.find_by(email: params['email'])
  if user
    if user.password == given_password
      p "User authenticated succesfuly"
      session[:user_id] = user.id
      redirect "/feed"
    else
      p "Wrong credentials entered"
      redirect "/login"
    end
  end
end

get "/feed" do
  if session[:user_id]
    erb :feed
  else
    redirect "/"
  end
end

post "/logout" do
  session.clear
  p "You have been logged out"
end

get "/profile" do
  erb :profile
end
