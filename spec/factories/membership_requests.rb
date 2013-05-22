# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :membership_request do
    name "MyString"
    email "MyString"
    user_id 1
  end
end
