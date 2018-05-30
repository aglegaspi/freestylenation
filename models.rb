require 'sinatra/activerecord'

class User < ActiveRecord::Base
    has_many :entries
end

class Entry < ActiveRecord::Base
    belongs_to :user
end