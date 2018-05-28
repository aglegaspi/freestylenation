require 'sinatra'
require 'mailgun'
require './models'


get '/' do
#	@todos = Todo.all
	erb :index
end
#
#get '/todo/new' do
#	erb :new
#end
#
#post '/todo/create' do
#	Todo.create(name: params[:name], description: params[:description])
#
#	redirect '/'
#end
#
#get '/todo/edit/:id' do
#	@todo = Todo.find(params[:id])
#
#	erb :edit
#end
#
#post '/todo/update/:id' do
#	todo = Todo.find(params[:id])
#	todo.update(name: params[:name], description: params[:description])
#
#	redirect '/'
#end
#
#get '/todo/delete/:id' do
#    todo = Todo.find(params[:id])
#    todo.destroy()
#
#    redirect '/'
#end
