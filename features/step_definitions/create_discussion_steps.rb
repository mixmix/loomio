Given /^I am viewing a discussion titled "(.*?)" in "(.*?)"$/ do |disc_title, group_name|
  @discussion = FactoryGirl.create :discussion,
               :title => disc_title, :group => Group.find_by_name(group_name)
  visit discussion_path(@discussion)
end

When /^I choose to create a discussion$/ do
  click_link 'Start a discussion'
end

When /^I select the group from the groups dropdown$/ do
  select @group.name, from: 'discussion_group_id'
end

When /^I fill in the discussion details and submit the form$/ do
  @discussion_title = Faker::Lorem.sentence
  @discussion_description = Faker::Lorem.paragraph+'*markdown*'
  fill_in 'discussion_title', with: @discussion_title
  fill_in 'discussion_description', with: @discussion_description
  click_on 'discussion-submit'
end

Then /^a discussion should be created$/ do
  Discussion.where(:title => @discussion_title).should exist
end

Given /^"(.*?)" has chosen to be emailed about new discussions and decisions for the group$/ do |arg1|
  @notified_user = User.find_by_name arg1
  @notified_user.memberships.where(:group_id => @group.id).update_all(:subscribed_to_notification_emails => true)
end

Given /^"(.*?)" has chosen not to be emailed about new discussions and decisions for the group$/ do |arg1|
  @unnotified_user = User.find_by_name arg1
  @unnotified_user.memberships.where(:group_id => @group.id).update_all(:subscribed_to_notification_emails => false)
end

Then /^"(.*?)" should be emailed about the new discussion$/ do |arg1|
  open_email(@notified_user.email, :with_subject => "New discussion")
  current_email.default_part_body.to_s.should include(@discussion_title && "unsubscribe")
end

Then /^clicking the link in the email should take him to the discussion$/ do
  click_first_link_in_email
  page.should have_content(@discussion_title)
end

####
Given /^my global markdown preference is 'disabled'$/ do
  step "I don't prefer markdown"
end

When /^I see discussion markdown is disabled$/ do
  page.should have_css('.markdown-off')
end

When /^I enable markdown for the discussion description$/ do
  click_on 'discussion-markdown-dropdown-link'
  find('#discussion-markdown-dropdown .enable-markdown').click
end

Then /^the discussion desription should render markdown$/ do
  find('.description-body').should_not have_content('*markdown*')
  find('.description-body').should have_content('markdown')
end

Then /^my global markdown preference should now be 'enabled'$/ do
  step 'comment markdown should now be on by default'
end
