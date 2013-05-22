require 'spec_helper'

describe MembershipRequest do
  let(:group) {FactoryGirl.create(:group)}

  subject do
    @membership_request = MembershipRequest.new(name: 'Bob Dogood',
                                               email: 'this@that.org.nz',
                                               group: group)
  end

  describe 'new' do
    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:group) }

    it { should be_valid }
  end

  it "must have a valid email" do
    email = '"Joe Gumby" <joe@gumby.com>'
    valid?
    should have(1).errors_on(:email)
  end

  it "should allow apostrophels in email addresses" do
    email = "D'aRCY@kiwi.NZ"
    should be_valid
  end


  it "must have only one membership_request for each user email/group pair" do
    # pending
  end
end
