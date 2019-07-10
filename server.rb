require "sinatra"
require "sinatra/activerecord"

#LOCAL
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: './database.sqlite3')
set :database, {adapter: "sqlite3", database: "./database.sqlite3"}

#HEROKU
# require "active_record"
# ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

enable :sessions

class User < ActiveRecord::Base
end

get '/' do
  if session[:user]
    redirect "/feed"
  else
    erb :home
  end
end

get '/signup' do
  if session[:user]
    redirect "/feed"
  else
    erb :signup
  end
end

post "/signup" do
  valid = true
  valid = false if params[:first_name].gsub!(/[^0-9A-Za-z]/,'') == '' 
  valid = false if params[:last_name].gsub!(/[^0-9A-Za-z]/,'') == ''
  valid = false if params[:birthday] == ''
  valid = false if params[:email] == ''
  valid = false if params[:password] == ''
  valid = false if params[:password].length < 8
  if valid == false
    p "Invalid argument"
    break
  else
    @user = User.new(params)
    if @user.save
      p "#{@user.first_name} was saved to the database"
      redirect "/thanks"
    end
  end
end

get "/thanks" do
  erb :thanks
end

get '/login' do
  if session[:user]
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
      session[:user] = user.id
      redirect "/feed"
    else
      p "Wrong credentials entered"
      redirect "/login"
    end
  end
end

get "/feed" do
  if session[:user]
    erb :feed
  else
    redirect "/"
  end
end

get "/logout" do
  redirect "/"
end

post "/logout" do
  session.clear
  redirect "/"
end

get "/profile" do
  @user = User.find_by(id: session[:user])
  erb :profile
end
