class Message < ActiveRecord::Base
  validates :user_id, :presence => true
  validates :text, :presence => true
  belongs_to :user
  attr_accessible :text
end
