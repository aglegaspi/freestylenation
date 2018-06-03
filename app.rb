require 'sinatra'
require 'mailgun'
require './models'

set :session_secret, ENV['RUMBLR_SESSION_SECRET']
enable :sessions

    #this method checks if user is logged in or not then directs accordingly
        get '/' do
            if session[:user_id]
                redirect '/dashboard'
            else
                redirect '/login'
            end
        end

    #the sign up page
        get('/signup') do
            erb :signup
        end

    #this method check if user is signed in 
        post('/signup') do
            existing_user = User.find_by(email: params[:email])
            if existing_user != nil
                return redirect '/login'
            end

            user = User.create(
                first_name: params[:first_name],
                last_name: params[:last_name],
                nickname: params[:nickname],
                email: params[:email],
                password: params[:password],
            )
            session[:user_id] = user.id
            redirect '/dashboard'
        end


        get('/login') do 
            if session[:user_id] == true
                return redirect '/dashboard'
            end
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

            @entries = Entry.last(20)
            @user = User.find(user_id)
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
