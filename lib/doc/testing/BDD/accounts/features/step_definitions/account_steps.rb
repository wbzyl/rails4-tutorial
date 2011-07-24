Given /^I have an account$/ do
  #pending # express the regexp above with the code you wish you had
  @account = Account.new
end

Given /^it has a balance of (\d+)$/ do |amount|
  @account.balance = amount.to_i
end

When /^I take out (\d+)$/ do |amount|
  @account.balance -= amount.to_i
  # @account.balance = @account.balance - amount
end

Then /^my balance should be (\d+)$/ do |amount|
  @account.balance.should eql(amount.to_i)
end
