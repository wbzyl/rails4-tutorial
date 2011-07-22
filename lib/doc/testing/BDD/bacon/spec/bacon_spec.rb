require 'bacon'

describe Bacon do

  subject { Bacon.new }

  # it "is edible" do
  #   Bacon.new.edible?.should be_true
  # end

  its(:edible?) { should be_true }

  # it "is edible" do
  #   Bacon.edible?.should be_true
  # end

  it "expired!" do
    subject.expired!
    subject.should_not be_edible
  end

  # it "expired!" do
  #   bacon = Bacon.new
  #   bacon.expired!
  #   bacon.should be_expired
  # end

end
