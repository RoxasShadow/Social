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
