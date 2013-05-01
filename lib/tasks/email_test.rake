include ERB::Util
require 'spec_helper'

require 'faker'

# require 'factory_girl_rails'
# FactoryGirl.find_definitions
describe "Email formatting" do
  it "email_test:discussion:new_discussion_created" do
    let(:user) { stub_model User }

  end

end


class FakeThing
  def make_attrs
    instance_variables.each do |var|
      self.class.class_eval { attr_accessor var.to_s.gsub('@', '') }
    end
  end
  def override_defaults(args)
    args.each_pair do |key, value|
      instance_variable_set "@#{key}", value
    end
  end
end

###############

class FakeUser < FakeThing
  def initialize(args={})
    @name = Faker::Name.name
    @email = Faker::Internet.email
    @uses_markdown = true
    @unsubscribe_token = ('a'..'z').to_a.sample(25).join
    @invitation_token = ('a'..'z').to_a.sample(25).join
    make_attrs
    override_defaults(args)
  end
end

class FakeGroup < FakeThing
  def initialize(args={})
    @id = rand(1..100)
    @name = Faker::Name.name
    @full_name = "Parent - " + @name
    @admin_email = Faker::Internet.email
    make_attrs
    override_defaults(args)
  end
end

class FakeDiscussion < FakeThing
  def initialize(args={})
    @title = Faker::Name.title
    @group = FakeGroup.new
    make_attrs
    override_defaults(args)
  end
end

class FakeComment < FakeThing
  def initialize(args={})
    @author = FakeUser.new
    @discussion = FakeDiscussion.new
    @group = FakeGroup.new
    @id = rand(300..1200)
    @body = Faker::Lorem.paragraph(rand(3..7))
    @uses_markdown = true
    make_attrs
    override_defaults(args)
  end
end

class FakeMotion < FakeThing
  def initialize(args={})
    @group = FakeGroup.new
    @discussion = FakeDiscussion.new
    @name = Faker::Name.title
    @author = FakeUser.new
    @close_date = Time.now
    @description = Faker::Lorem.paragraph(rand(4..12))
    @votes_for_graph = [["Yes (1)", 1, "Yes", [["himful@gmail.com"]]], ["Abstain (0)", 0, "Abstain", [[]]], ["No (0)", 0, "No", [[]]], ["Block (1)", 1, "Block", [["bob@lick.com"]]]]
    @unique_votes = []
    rand(2..11).times {@unique_votes << FakeVote.new }
    @percent_voted = 50
    @group_count = 22
    @no_vote_count =11
    make_attrs
    override_defaults(args)
  end
end

class FakeVote < FakeThing
 def initialize(args={})
    @user_name = Faker::Name.name
    @position_to_s = ['agreed', 'abstained', 'disagreed', 'blocked'].sample
    @statement = Faker::Lorem.paragraph(rand(1..3))
    make_attrs
    override_defaults(args)
  end
end

class FakeMembership < FakeThing
 def initialize(args={})
    @user = FakeUser.new
    @inviter = FakeUser.new
    @group = FakeGroup.new
    make_attrs
    override_defaults(args)
  end
end


###############

addresses = [ 'john.irving@enspiral.com', 'loomio.test.account@outlook.com', 'loomio.testaccount@yahoo.com', 'loomio.testaccount@loomio.org' ]

###############

namespace :email_test do

  # if Rails.env != 'test'
  #   puts 'RAKE ABORTED!'
  #   puts 'only run this command in staging ENV.'
  #   puts 'run RAILS_ENV=test ENABLE_TEST_EMAILS=true rake email_test:MAILER_NAME'
   # RAILS_ENV=test TEST_EMAIL=mailcatcher rails runner lib/tasks/email_test.rb
  #   next
  # end

  task :all => :environment do
    Rake::Task["email_test:discussion:all"].invoke
    Rake::Task["email_test:group:all"].invoke
    Rake::Task["email_test:start_group:all"].invoke
    Rake::Task["email_test:motion:all"].invoke
    Rake::Task["email_test:user:all"].invoke
    Rake::Task["email_test:woc:all"].invoke
  end

  namespace :discussion do
    task :all => :environment do
      Rake::Task["email_test:discussion:new_discussion_created"].invoke
    end

    task :new_discussion_created => :environment do
      puts 'NEW_DISCUSSION_CREATED'
      @user = FactoryGirl.build(:user)
      @discussion = FactoryGirl.build(:discussion)
      @discussion.id = rand(1..1000)

      addresses.each do |email|
        @user.email = email
        DiscussionMailer.new_discussion_created(@discussion, @user).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end

  namespace :group do
    task :all => :environment do
      Rake::Task["email_test:group:new_membership_request"].invoke
      Rake::Task["email_test:group:group_email"].invoke
      Rake::Task["email_test:group:deliver_group_email"].invoke
    end

    task :new_membership_request => :environment do
      puts 'NEW_MEMBERSHIP_REQUEST'
      @membership = FactoryGirl.build(:membership)
      @admin = @membership.group.admins[0]
      @membership.group.admins = [@admin]

      addresses.each do |email|
        @admin.email = email
        GroupMailer.new_membership_request(@membership).deliver
        puts " ~ SENT (#{email})"
      end
    end

    task :group_email => :environment do
      puts 'GROUP_EMAIL'
      @group = FactoryGirl.build(:group)
      @group.id = rand(1..500)
      @sender = FactoryGirl.build(:user)
      @subject = Faker::Lorem.sentence(4)
      @message = Faker::Lorem.paragraph(4)
      @recipient = FactoryGirl.build(:user)

      addresses.each do |email|
        @recipient.email = email
        GroupMailer.group_email(@group, @sender, @subject, @message, @recipient).deliver
        puts " ~ SENT (#{email})"
      end
    end

    task :deliver_group_email => :environment do
      puts 'DELIVER_GROUP_EMAIL'
      @group = FactoryGirl.build(:group)
      @sender = FactoryGirl.build(:user)
      @subject = Faker::Lorem.sentence(4)
      @message = Faker::Lorem.paragraph(4)

      addresses.each do |email|
        GroupMailer.deliver_group_email(@group, @sender, @subject, @message).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end

  namespace :motion do
    task :all => :environment do
      Rake::Task["email_test:motion:new_motion_created"].invoke
      Rake::Task["email_test:motion:motion_closed"].invoke
      Rake::Task["email_test:motion:motion_blocked"].invoke
    end

    task :new_motion_created  => :environment do
      puts 'NEW_MOTION_CREATED'
      @motion = FactoryGirl.build(:motion)
      @user = FactoryGirl.build(:user)

      addresses.each do |email|
        @user.email = email
        MotionMailer.new_motion_created(@motion, @user).deliver
        puts " ~ SENT (#{email})"
      end
    end

    task :motion_closed => :environment do
      puts 'MOTION_CLOSED'
      @motion = FactoryGirl.build(:motion)
      @email = ''
      addresses.each do |email|
        @email = email
        MotionMailer.motion_closed(@motion, @email).deliver
        puts " ~ SENT (#{email})"
      end
    end

    task :motion_blocked => :environment do
      puts 'MOTION_BLOCKED'
      @vote = FactoryGirl.build(:vote)
      @vote.id = rand(1..1000)

      addresses.each do |email|
        @vote.motion.author.email = email
        MotionMailer.motion_blocked(@vote).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end

  namespace :start_group do
    task :all => :environment do
      Rake::Task["email_test:start_group:invite_admin_to_start_group"].invoke
    end

    task :invite_admin_to_start_group => :environment do
      puts 'INVITE_ADMIN_TO_START_GROUP'
      @group_request = FactoryGirl.build(:group_request)
      @group_request.id = rand(1000)
      @group_request.token = ('a'..'z').to_a.sample(25).join

      addresses.each do |email|
        @group_request.admin_email = email
        StartGroupMailer.invite_admin_to_start_group(@group_request).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end

  namespace :user do
    task :all => :environment do
      Rake::Task["email_test:user:daily_activity"].invoke
      Rake::Task["email_test:user:mentioned"].invoke
      Rake::Task["email_test:user:group_membership_approved"].invoke

      Rake::Task["email_test:user:motion_closing_soon"].invoke
      Rake::Task["email_test:user:added_to_group"].invoke
      Rake::Task["email_test:user:invited_to_loomio"].invoke
    end

    task :daily_activity => :environment do
      puts 'DAILY_ACTIVITY'
      @user = FactoryGirl.build(:user)

      @activity = {}
      R = rand(2000)
      (3..rand(4..6)).each do |i| #fake a group and attach it
        h = {}
        group = FactoryGirl.build(:group, id: i+R)
        @user.groups << group

        (0..rand(3)).each do |j|   #fake some discussions and attach to group
          discussion = FactoryGirl.build(:discussion, id: j+R)
          group.discussions << discussion

          comments = []
          (0..rand(3)).each do |l|  # fake some new comments and add to discussion
            comment = FactoryGirl.build(:comment, created_at: Time.now)
            comments << comment
          end
          discussion.comments = comments
        end
        h[:discussions] = group.discussions

        motions = []             #fake some motions and attach to group
        (0..rand(2)).each do |k|
          motion = FactoryGirl.build(:motion, id: k+R, close_date: Time.now + rand(200).hours)
          motions << motion
        end
        h[:motions] = motions

        @activity[group.full_name] = h
      end

      @since_time = Time.now - 5.hours

      addresses.each do |email|
        @user.email = email
        UserMailer.daily_activity(@user, @activity, @since_time).deliver
        puts " ~ SENT (#{email})"
      end
    end

    task :mentioned => :environment do
      puts 'MENTIONED'
      @group = FakeGroup.new
      @comment_body = "have you see www.stuff.co.nz ? Foreman <a href=\"www.maliciouscode.com\" style=\"font-color:red\">can</a> help manage multiple processes that your Rails app depends upon when running in development. @johnirving would like this. It also provides an export command to move them into production. it's objectively the *best* for:\r\n \r\n- news \r\n- __stuff__ \r\n- things\r\n \r\n---\r\n \r\n## the `code` test section: \r\n \r\n```\r\nquestion = 'does it work'\r\nputs \" \#{question} ?\"\r\n```\r\n\r\n### also\r\n\r\nhere's a mockup of this email (how meta):\r\n[![](http://i.imgur.com/oLzk6ay.png)](http://i.imgur.com/oLzk6ay.png)"
      @comment = FakeComment.new body: @comment_body
      @mentioned_user = FakeUser.new name: 'Mentioned User'

      mailer_methods = {
      :mentioned_with_markdown => lambda do |email|
        @mentioned_user.email = email
        @group.name = "User mentioned WITH MARKDOWN"
        UserMailer.mentioned(@mentioned_user, @comment)
      end,

      :mentioned_without_markdown => lambda do |email|
        @mentioned_user.email = email
        @group.name = "User mentioned WITHOUT MARKDOWN"
        @comment.uses_markdown = false
        UserMailer.mentioned(@mentioned_user, @comment)
      end
      }

      addresses.each do |email|
        mailer_methods.each do |key, mailer_method|
          mailer_method.call(email).deliver
          puts " ~ SENT: (#{email}) : #{key}"
        end
      end
    end

    task :group_membership_approved => :environment do
      puts 'GROUP_MEMBERSHIP_APROVED'
      @group = FakeGroup.new

      addresses.each do |email|
        @user = FakeUser.new email: email
        UserMailer.group_membership_approved(@user, @group).deliver
        puts " ~ SENT (#{email})"
      end
    end

    task :motion_closing_soon => :environment do
      puts 'MOTION_CLOSING_SOON'
      @motion = FakeMotion.new
      @user = FakeUser.new

      addresses.each do |email|
        @user.email = email
        UserMailer.motion_closing_soon(@user, @motion).deliver
        puts " ~ SENT (#{email})"
      end
    end

    task :added_to_group => :environment do
      puts 'ADDED_TO_GROUP'
      @membership = FakeMembership.new

      addresses.each do |email|
        @membership.user.email = email
        UserMailer.added_to_group(@membership).deliver
        puts " ~ SENT (#{email})"
      end
    end

    task :invited_to_loomio => :environment do
      puts 'INVITED_TO_LOOMIO'
      @new_user = FactoryGirl.build(:user)
      @new_user.unsubscribe_token = ('a'..'z').to_a.sample(25).join
      @new_user.invitation_token = ('a'..'z').to_a.sample(25).join

      @inviter = FactoryGirl.build(:user)
      @group = FakeGroup.new

      addresses.each do |email|
        @new_user.email = email
        UserMailer.invited_to_loomio(@new_user, @inviter, @group).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end

end
