class MembershipRequest < ActiveRecord::Base
  attr_accessible :name, :email, :group_id, :user_id

  validates :name,  presence: true
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  #fails to allow apostrophes. how does loomio ensure valid emails. or is that simple_form
  validates :email, presence: true#, format: { with: VALID_EMAIL_REGEX }
  validates :group, presence: true

  before_save { |request| request.email = email.downcase }

end
