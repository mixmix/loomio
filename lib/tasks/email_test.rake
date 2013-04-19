include ERB::Util
require 'faker'

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
  include ActiveModel::Model

  def initialize(args={})
    @name = Faker::Name.name
    @email = Faker::Internet.email
    @uses_markdown = true
    @unsubscribe_token = ('a'..'z').to_a.sample(25).join
    @invitation_token = ('a'..'z').to_a.sample(25).join
    make_attrs
    override_defaults(args)
  end

   ##### need to find a way for accept_invitatation_url to think this is a User class object (not fakeuser)
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

  if Rails.env != 'staging'
    puts 'RAKE ABORTED!'
    puts 'only run this command in staging ENV.'
    puts 'run RAILS_ENV=staging ENABLE_STAGING_EMAILS=true rake email_test:MAILER_NAME'
    next
  end

  task :all => :environment do
    Rake::Task["email_test:daily_activity"].invoke
    Rake::Task["email_test:mentioned"].invoke
    Rake::Task["email_test:group_membership_approved"].invoke

    Rake::Task["email_test:motion_closing_soon"].invoke
    Rake::Task["email_test:added_to_group"].invoke
    Rake::Task["email_test:invited_to_loomio"].invoke

    Rake::Task["email_test:"].invoke
    Rake::Task["email_test:"].invoke
  end

  task :daily_activity => :environment do
    puts 'DAILY_ACTIVITY'
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
      puts "EMAIL: #{email}"
      mailer_methods.each do |key, mailer_method|
        mailer_method.call(email).deliver
        puts " ~ SENT: #{key}"
      end
    end
  end

  task :group_membership_approved => :environment do
    puts 'GROUP_MEMBERSHIP_APROVED'
    @group = FakeGroup.new

    addresses.each do |email|
      @user = FakeUser.new email: email
      UserMailer.group_membership_approved(@user,@group).deliver
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
    @new_user = FakeUser.new
    @inviter = FakeUser.new
    @group = FakeGroup.new

    addresses.each do |email|
      @new_user.email = email
      UserMailer.invited_to_loomio(@new_user, @inviter, @group).deliver
      puts " ~ SENT (#{email})"
    end
  end
end