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
