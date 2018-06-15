require 'sinatra'
require 'mailgun'
require './models'


set :session_secret, ENV['RUMBLR_SESSION_SECRET']
enable :sessions

#this method calls the root page and executes
get '/' do
    #checks if the user is logged in
    if session[:user_id]
        #when true the user is redirected to dashboard
        redirect '/dashboard'
    else
        #when not true the user is sent to the login page
        redirect '/login'
    end
end

#this method calls the signup page and executes
get('/signup') do
    #loads the embeded ruby file called sign up
    erb :signup
end

#this post method is called on signup and executes
post('/signup') do
    #we create a variable that finds an existing user with this email
    existing_user = User.find_by(email: params[:email])
    #if we were to find exisiting user then we want to prevent signing up with same email so we redirect user to login page. 
    if existing_user != nil
        return redirect '/login'
    end
    
    #we create a variable instance of User with all the values submitted, and creates this row in the database.
    user = User.create(
        #columns           #values
        first_name: params[:first_name],
        last_name: params[:last_name],
        nickname: params[:nickname],
        email: params[:email],
        password: params[:password],
    )
    #then we assign the user's id to the session id and redirect.
    session[:user_id] = user.id
    redirect '/dashboard'
end

#this method is for login and executes
get('/login') do 
    #if the user is logged in we automatically send them to the dashboard
    if session[:user_id]
        return redirect '/dashboard'
    end
    #if not they will see contents of the login embed ruby
    erb :login	
end

#this POST method calls the login and executes
post('/login') do
    #we're finding a user by email and saving it in a variable
    user = User.find_by(email: params[:email])
    #if there is not a user that exists with an email then user is redirected
    if user.nil?
        puts "Invalid UN: #{params[:email]}"
        return redirect '/login'
    end
    #checking if password types equals to passwor in database    
    unless user.password == params[:password]
        #if password does not match then it will log the following
        puts "Invalid PW: #{params[:password]}, expected: #{user.password}"
        return redirect '/login'
    end
    
    #we set session user id to log them in and redirect
    session[:user_id] = user.id
    redirect '/dashboard'
end


get('/dashboard') do
    #this check to see if the user is logged in if not then redirect 
    if session[:user_id].nil?
        return redirect '/'
    end

    #creating instance var of the last 20 items the Entry table.
    @entries = Entry.last(20)
    #creating an instance var that allows to call all the column values (aka methods)
    
    @user = User.find(session[:user_id])
    
    erb :dashboard
end	

#THIS IS THE ENTRIES REQUESTS AND METHODS
get '/entry/new' do
    user_id = session[:user_id]
    if user_id.nil?
        return redirect '/'
    end

    erb :new
end

post '/entry/create' do
    user_id = session[:user_id]
    if user_id.nil?
        return redirect '/'
    end

    Entry.create(title: params[:title], message: params[:message], user_id: session[:user_id])

    redirect '/'
end

get '/entry/edit/:id' do
    if session[:user_id].nil?
        return redirect '/'
    end

    @entry = Entry.find(params[:id])

    if session[:user_id] != @entry.user_id
        return redirect '/dashboard'
    end

    erb :edit
end

post '/entry/update/:id' do
    if session[:user_id].nil?
        return redirect '/'
    end

    entry = Entry.find(params[:id])

    if session[:user_id] != entry.user_id
        return redirect '/dashboard'
    end

    entry.update( title: params[:title], message: params[:message])
    redirect '/'
end

get '/entry/delete/:id' do
    if session[:user_id].nil?
        return redirect '/'
    end

    entry = Entry.find(params[:id])

    if session[:user_id] != entry.user_id
        return redirect '/dashboard'
    end

    entry.destroy()
    redirect '/'
end




#THESE ARE THE PROFILE REQUESTS AND METHODS

get '/profile/:id' do
    if session[:user_id].nil?
        return redirect '/'
    end

    @user = User.find(params[:id])
    @entries = Entry.where(user_id: params[:id])
    erb :profile
end

post '/profile/update/:id' do
    if session[:user_id].nil?
        return redirect '/'
    end

    user = User.find(params[:id])
#	user.update(title: params[:title], message: params[:message])
    redirect '/'
end

get '/profile/delete/:id' do
    if session[:user_id].nil?
        return redirect '/'
    end

    user = User.find(params[:id])

    #this uses the class in methods.rb and the relation becomes a method
    user.entries.each do |post|
       post.destroy 
    end

    user.destroy
    session[:user_id] = nil
    redirect '/'
end

get '/freestyle' do
    
    erb :freestyle
end


get '/logout' do
    session[:user_id] = nil
    redirect '/'
end
