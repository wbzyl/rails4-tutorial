require 'bacon'

describe Bacon do

  it "is edible" do
    Bacon.edible?.should be_true
  end

end
