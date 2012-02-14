class User
	include DataMapper::Resource
	property :id,         Serial
	property :name,       String,
				:required => true,
				:messages => {
					:precence  => error!({ 'error' => :required, 'what' => :name      }, 400)
				}
	property :surname,    String,
				:required => true,
				:messages => {
					:precence  => error!({ 'error' => :required, 'what' => :surname   }, 400)
				}
	property :nickname,   String,
				:key      => true,
				:unique   => true,
				:required => true,
				:messages => {
					:is_unique => error!({ 'error' => :duplicate, 'what' => :nickname }, 400),
					:precence  => error!({ 'error' => :required,  'what' => :nickname }, 400)
				}
	property :email,      String,
				:key      => true,
				:unique   => true,
				:required => true,
				:format   => :email_address,
				:messages => {
					:is_unique =>  error!({ 'error' => :duplicate, 'what' => :email   }, 400),
					:precence  =>  error!({ 'error' => :required,  'what' => :email   }, 400),
					:format    =>  error!({ 'error' => :not_valid, 'what' => :email   }, 400)
				}
	property :password,   String,
				:required => true,
				:messages => {
					:precence  =>  error!({ 'error' => :required, 'what' => :password }, 400)
				}
	property :gender,     String,
				:required => true,
				:length   => 1, # 0 => male, 1 => female
				:messages => {
					:precence  =>  error!({ 'error' => :required, 'what' => :gender   }, 400),
					:length    =>  error!({ 'error' => :length,   'what' => 1         }, 400)
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
