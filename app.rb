require 'sinatra'
require 'mailgun'
require './models'

set :session_secret, ENV['RUMBLR_SESSION_SECRET']
enable :sessions

#get('/') do
#	erb :index
#end

get '/' do
    if session[:user_id]
        redirect '/dashboard'
    else
        redirect '/login'
    end
end


get('/signup') do
	erb :signup
end

post('/signup') do
	existing_user = User.find_by(email: params[:email])
	if existing_user != nil
		return redirect '/login'
	end

	user = User.create(
		first_name: params[:f_name],
  		last_name: params[:l_name],
  		email: params[:email],
  		password: params[:password],
	)
	session[:user_id] = user.id
	redirect '/dashboard'
end

get('/login') do 
	erb :login	
end

post('/login') do
	user = User.find_by(email: params[:email])
	if user.nil?
        puts "Invalid UN: #{params[:email]}"
		return redirect '/login'
	end

	unless user.password == params[:password]
        puts "Invalid PW: #{params[:password]}, expected: #{user.password}"
		return redirect '/login'
	end

	session[:user_id] = user.id
	redirect '/dashboard'
end


get('/dashboard') do
	user_id = session[:user_id]
	if user_id.nil?
		return redirect '/'
	end
    
    @entries = Entry.all
    
	@user = User.find(user_id)
	erb :dashboard
end	



THIS IS THE 

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
    
	entry.update(title: params[:title], message: params[:message])

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











get '/logout' do
    session.clear
    redirect '/'
end
