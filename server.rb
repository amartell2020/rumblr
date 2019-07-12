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

class Post < ActiveRecord::Base
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
  valid = false if params[:first_name].gsub!(/[^0-9A-Za-z]/,'') == '' || params[:first_name] == ''
  valid = false if params[:last_name].gsub!(/[^0-9A-Za-z]/,'') == '' || params[:last_name] == ''
  valid = false if params[:birthday] == ''
  valid = false if params[:email] == ''
  valid = false if params[:password] == ''
  valid = false if params[:password].length < 8
  if valid == false
    @alert = true
    erb :"/signup"
  else
    @user = User.new(params)
    if @user.save
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
      redirect "/login"
    end
  end
end

get "/feed" do
  @posts = Post.all
  if session[:user]
    erb :feed
  else
    redirect "/"
  end
end

post "/feed" do
  user = User.find_by(id: session[:user])
  @post = Post.new(title: params[:title], content: params[:content], user_id: session[:user])
  @post.save
  @post.update(creator: user.first_name)
  redirect "/feed"
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
  @posts = Post.all
  erb :profile
end

post "/profile" do
  @posts = Post.all
  id = post.id
  p = Post.find_by(id: id)
  @posts.destroy(p)
  redirect "/profile"
end

post "/delete" do
  user = User.find_by(id: session[:user])
  user.destroy
  session.clear
  redirect "/terminated"
end

get "/terminated" do
  erb :terminated
end
