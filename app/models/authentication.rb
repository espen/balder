class Authentication < ActiveRecord::Base
  belongs_to :user
  validates :uid, :provider, :presence => true
  validates_uniqueness_of :uid, :scope => :provider
end
