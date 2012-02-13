require 'sinatra'
require 'haml'
require 'htmlentities'
require 'digest/md5'
require 'data_mapper'
require 'sinatra/resources'
require 'json'

enable :sessions

helpers do	
	def timestamp
		Time.now.getutc
	end
	
	def rng(len)
		chars = (?a..?z).to_a + (?A..?Z).to_a + (?0..?9).to_a
		charlen = chars.size
		seq = ''
		len.times { seq << chars[rand(charlen-1)] }
		seq
	end
		
	def init_db(db, debug, migrate)
		DataMapper::Logger.new($stdout, :debug) if debug
		DataMapper.setup(:default, db)
		DataMapper.auto_upgrade!
		DataMapper.auto_migrate! if migrate
	end
	
	def logged?
		false unless session[:sessid]
		User.exists? session[:sessid]
	end
	
	def current_user
		User.get(session[:sessid])
	end
	
	def login(nickname, password, sessid)
		if User.count(:nickname => nickname, :password => password) > 0
			session[:sessid] = sessid
			false unless User.first(:nickname => nickname, :password => password).update(:sessid => sessid)
		end
		logged?
	end
	
	def logout
		User.get(session[:sessid]).update(:sessid => '')
		session[:sessid] = ''
		!logged?
	end
end

class String
	def cut(limit)
		self.match(%r{^(.{0,#{limit}})})[1]
	end
	
	def md5
		Digest::MD5.hexdigest(self)
	end
	
	def to_entities
		HTMLEntities.new.encode(self, :named)
	end
	
	def numeric?
		self.to_i.to_s == self || self.to_f.to_s == self
	end
end

class Status
	OK = '0'
	ERROR = '1'
	REQUIRE_LOGIN = '2'
	REQUIRE_LOGOUT = '3'
	
	def Status.error(error, what, addon='')
		"{'error': '#{error}', 'what': '#{what}', 'addon':'#{addon}'"
	end
end

class User
	include DataMapper::Resource
	property :id,         Serial
	property :name,       String,
				:required => true,
				:messages => {
					:precence => Status.error(:required, :name)
				}
	property :surname,    String,
				:required => true,
				:messages => {
					:precence => Status.error(:required, :surname)
				}
	property :nickname,   String,
				:key => true,
				:unique => true,
				:required => true,
				:messages => {
					:is_unique => Status.error(:unique, :nickname),
					:precence => Status.error(:required, :nickname)
				}
	property :email,      String,
				:key => true,
				:unique => true,
				:required => true,
				:format => :email_address,
				:messages => {
					:is_unique => Status.error(:unique, :email),
					:precence => Status.error(:required, :email),
					:format => Status.error(:email_address_format, :email)
				}
	property :password,   String,
				:required => true,
				:messages => {
					:precence => Status.error(:required, :password)
					#:length => Status.error(:length, :password, 6..32)
				}
	property :gender,     String,
				:required => true,
				:length => 1, # 0 => male, 1 => female
				:messages => {
					:precence => Status.error(:required, :gender),
					:length => Status.error(:length, :gender, 1)
				}
	property :sessid,     String
	
	def self.get(what)
		what = what.to_s
		if what.numeric?
			User.first(:id => what)
		elsif what.strip.length == 32
			User.first(:sessid => what)
		elsif what.strip.length == 0
			nil
		else
			User.first(:nickname => what)
		end
	end
	
	def self.exists?(what)
		what = what.to_s
		if what.numeric?
			User.count(:id => what) > 0
		elsif what.strip.length == 32
			User.count(:sessid => what) > 0
		elsif what.strip.length == 0
			nil
		else
			User.count(:nickname => what) > 0
		end
	end
end

class Post
	include DataMapper::Resource
	property :id,         Serial
	property :sender,     String
	property :recipient,  String
	property :text,       Text
	property :timestamp,  DateTime
end

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
	return Status::REQUIRE_LOGOUT if logged?
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
	return Status::REQUIRE_LOGOUT if logged?
	sessid = rng(12).md5
	login(params[:nickname], params[:password], sessid) ? Status::OK : Status::ERROR
end

get '/social/user.logout' do
	return Status::REQUIRE_LOGIN unless logged?
	logout ? Status::OK : Status::ERROR
end

get '/social/user.logged' do
	logged? ? Status::OK : Status::ERROR
end

get '/social/user/?' do
	return Status::REQUIRE_LOGIN unless logged?
	# the fuck is that
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
