Given /^I have an account$/ do
  #pending # express the regexp above with the code you wish you had
  @account = Account.new
end

Given /^it has a balance of (\d+)$/ do |amount|
  #pending # express the regexp above with the code you wish you had
  @account.balance = amount
end

When /^I take out (\d+)$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^my balance should be (\d+)$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
