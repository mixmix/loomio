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
  def initialize(args={})
    @name = Faker::Name.name
    @email = Faker::Internet.email
    @uses_markdown = true
    @unsubscribe_token = ('a'..'z').to_a.sample(25).join
    make_attrs
    override_defaults(args)
  end
end

class FakeGroup < FakeThing
  def initialize(args={})
    @id = rand(1..100)
    @name = Faker::Name.name
    make_attrs
    override_defaults(args)
  end
end

class FakeDiscussion < FakeThing
  attr_accessor :title
  def initialize(args={})
    @title = Faker::Name.title
    make_attrs
    override_defaults(args)
  end
end

class FakeComment < FakeThing
  attr_accessor :author, :discussion, :group, :body, :uses_markdown, :id
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

addresses = [ 'john.irving@enspiral.com', 'loomio.test.account@outlook.com', 'loomio.testaccount@yahoo.com', 'loomio.testaccount@loomio.org' ]


namespace :email_test do

  task :all => :environment do
    Rake::Task["email_test:at_mention"].invoke
    Rake::Task["email_test:daily_activity"].invoke
  end

  task :daily_activity => :environment do

  end

  task :group_membership_approved => :environment do

  end

  task :at_mention => :environment do
    if Rails.env != 'staging'   ## can i put this at the top of this namespace
      puts 'RAKE ABORTED!'
      puts 'only run this command in staging ENV.'
      puts 'run RAILS_ENV=staging ENABLE_STAGING_EMAILS=true rake email_test:at_mention'
      next
    end

    time_stamp = Time.new
    @mentioner = FakeUser.new({name: 'Fake User One', email: 'not@gmail.com'})
    @group = FakeGroup.new({title: "Group #{time_stamp}"})
    # @discussion = FakeDiscussion.new('Should we support local stores or import?')
    @comment_body = "have you see www.stuff.co.nz ? Foreman <a href=\"www.maliciouscode.com\" style=\"font-color:red\">can</a> help manage multiple processes that your Rails app depends upon when running in development. @johnirving would like this. It also provides an export command to move them into production. it's objectively the *best* for:\r\n \r\n- news \r\n- __stuff__ \r\n- things\r\n \r\n---\r\n \r\n## the `code` test section: \r\n \r\n```\r\nquestion = 'does it work'\r\nputs \" \#{question} ?\"\r\n```\r\n\r\n### also\r\n\r\nhere's a mockup of this email (how meta):\r\n[![](http://i.imgur.com/oLzk6ay.png)](http://i.imgur.com/oLzk6ay.png)"
    @comment = FakeComment.new({author: @mentioner, group: @group, body: @comment_body})

    mailer_methods = {
    :user_mentioned_with_markdown => lambda do |email|
      mentioned_user = FakeUser.new({name: 'mentioned User', email: email})
      @group.name = "User mentioned WITH MARKDOWN #{time_stamp}"
      @comment.uses_markdown = true
      UserMailer.mentioned(mentioned_user, @comment)
    end,

    :user_mentioned_without_markdown => lambda do |email|
      mentioned_user = FakeUser.new({name: 'mentioned User', email: email})
      @group.name = "User mentioned WITHOUT MARKDOWN #{time_stamp}"
      @comment.uses_markdown = false
      UserMailer.mentioned(mentioned_user, @comment)
    end
    }


    #Mailers we are going to test?
    # Usermailer.mentioned
    # Usermailer.daily_activity
    # Usermailer.group_membership_approved

    # setup your mailers
    # set each up in its own method, returning the initailized but not delivered mailer
    # ending up with functions like build_user_mentioned_email
    # have an array of mailer names that maps to your build_mailername methods

    addresses.each do |email|
      puts "EMAIL: #{email}"
      mailer_methods.each do |key, mailer_method|
        mailer_method.call(email).deliver
        puts " ~ SENT: #{key}"
      end
    end
  end
end