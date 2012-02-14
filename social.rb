require 'sinatra'
require 'sinatra/error'
require 'haml'
require 'htmlentities'
require 'digest/md5'
require 'data_mapper'
require 'json'

require './extensions.rb'
require './helpers.rb'
require './social/status.rb'
require './social/user.rb'
require './social/post.rb'
enable :sessions

before do
	init_db("sqlite://#{Dir.pwd}/database.db", false, false)	
end

get '/social/?' do
	haml :index
end

get '/social/user.new' do
	#
end
	
post '/social/user.new' do
	error!({ 'error' => 'unauthorized', 'required' => 'logout' }, 401) if logged?
	User.create(
		:name		=>	params[:name],
		:surname	=>	params[:surname],
		:nickname	=>	params[:nickname],
		:email		=>	params[:email],
		:password	=>	params[:password],
		:gender		=>	params[:gender], 
		:sessid		=>	''
	).errors.each { |err| return err }
	User.exists?(params[:nickname]) ? Status::OK : Status::ERROR
end
	
get '/social/user.login' do
	#
end
	
post '/social/user.login' do
	error!({ 'error' => 'unauthorized', 'required' => 'logout' }, 401) if logged?
	sessid = rng(12).md5
	login(params[:nickname], params[:password], sessid) ? Status::OK : Status::ERROR
end

get '/social/user.logout' do
	error!({ 'error' => 'unauthorized', 'required' => 'login' },  401) unless logged?
	logout ? Status::OK : Status::ERROR
end

get '/social/user.logged' do
	logged? ? Status::OK : Status::ERROR
end
		
get '/social/user/?' do
	error!({ 'error' => 'unauthorized', 'required' => 'login' },  401) unless logged?
	u = current_user
	u.sessid = 'denied'
	u.password = 'denied'
	u.to_json
end

get '/social/user/:what' do
	u = User.get(params[:what])
	u.sessid = 'denied'
	u.password = 'denied'
	u.to_json
end
