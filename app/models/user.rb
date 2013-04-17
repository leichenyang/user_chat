class User < ActiveRecord::Base
  validates :name, :uniqueness =>true
  validates :name, :presence =>true
  has_many :messages
  attr_accessible :name
end
