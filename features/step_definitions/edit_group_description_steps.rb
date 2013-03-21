When /^I choose to edit the group description$/ do
  page.should have_css('#group-description-panel')
  # page.should have_content("Edit group")
  page.should have_css('.edit-group-description')
  find("#edit_description").click
  # click_link("edit_description")
end

When /^I fill in and submit the group description form$/ do
  @description_text = "This discussion is interesting"
  fill_in "description-input", :with  => @description_text
  click_on("add-description-submit")
end

Then /^I should see the group description change$/ do
  find('#discussion-context').should have_content(@description_text)
end

Then /^I should not see a link to edit the group description$/ do
  page.should_not have_css("edit_description")
end
