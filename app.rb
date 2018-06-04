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
            #we create a variable that finds the current users email
            existing_user = User.find_by(email: params[:email])
            #if the variable has value then they're redirected to login
            if existing_user != nil
                return redirect '/login'
            end
            #we create a variable instance of User with all the values submitted.
            user = User.create(
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

        #this method for login and executes
        get('/login') do 
            #if the user is logged in we automatically send them to the dashboard
            if session[:user_id] == true
                return redirect '/dashboard'
            end
            #if not they will see contents of the login embed ruby
            erb :login	
        end

        #this mthod call the login and executes
        post('/login') do
            #we create a variable instance of the current users email
            user = User.find_by(email: params[:email])
            #then we check to see if it has a value if not then they're sent to login
            if user.nil?
                puts "Invalid UN: #{params[:email]}"
                return redirect '/login'
            end
            #    
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
