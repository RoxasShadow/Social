class Post
	include DataMapper::Resource
	property :id,         Serial
	property :sender,     String
	property :recipient,  String
	property :text,       Text
	property :timestamp,  DateTime
end
