include ERB::Util

namespace :email_test do
  task :at_mention => :environment do
    if Rails.env != 'staging'
      puts 'RAKE ABORTED!'
      puts 'only run this command in staging ENV.'
      puts 'run RAILS_ENV=staging ENABLE_STAGING_EMAILS=true rake email_test:at_mention'
      next
    end

    class FakeUser
      attr_accessor :name, :email, :uses_markdown, :unsubscribe_token
      def initialize(name, email, uses_markdown=true, unsubscribe_token='barf')
        @name = name
        @email = email
        @uses_markdown = uses_markdown
      end
    end

    class FakeGroup
      attr_accessor :id, :name
      def initialize(id, name)
        @id = id
        @name = name
      end
    end

    class FakeDiscussion
      attr_accessor :title
      def initialize(title)
        @title = title
      end
    end

    class FakeComment
      attr_accessor :author, :discussion, :group, :body, :uses_markdown, :id
      def initialize(author, discussion, group, body, uses_markdown=true, id=333)
        @author = author
        @discussion = discussion
        @group = group
        @body = body
        @uses_markdown = uses_markdown
      end
    end

    time_stamp = Time.new
    @mentioner = FakeUser.new('Fake User One', 'not@gmail.com', true)
    @group = FakeGroup.new(2, "Group #{time_stamp}")
    @discussion = FakeDiscussion.new('Should we support local stores or import?')
    @comment_body = "have you see www.stuff.co.nz ? Foreman <a href=\"www.maliciouscode.com\" style=\"font-color:red\">can</a> help manage multiple processes that your Rails app depends upon when running in development. @johnirving would like this. It also provides an export command to move them into production. it's objectively the *best* for:\r\n \r\n- news \r\n- __stuff__ \r\n- things\r\n \r\n---\r\n \r\n## the `code` test section: \r\n \r\n```\r\nquestion = 'does it work'\r\nputs \" \#{question} ?\"\r\n```\r\n\r\n### also\r\n\r\nmy favourite comic:\r\n[![](http://i.imgur.com/oLzk6ay.png)](http://i.imgur.com/oLzk6ay.png)"
    @comment = FakeComment.new(@mentioner, @discussion, @group, @comment_body, true)


    addresses = [ 'john.irving@enspiral.com', 'loomio.test.account@outlook.com', 'loomio.testaccount@yahoo.com', 'loomio.testaccount@loomio.org' ]

    mailer_methods = {
    :user_mentioned_with_markdown => lambda do |email|
      mentioned_user = FakeUser.new('mentioned User', email)
      @group.name = "User mentioned with markdown #{time_stamp}"
      @comment.uses_markdown = true
      UserMailer.mentioned(mentioned_user, @comment)
    end,

    :user_mentioned_without_markdown => lambda do |email|
      mentioned_user = FakeUser.new('mentioned User', email)
      @group.name = "User mentioned without markdown #{time_stamp}"
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