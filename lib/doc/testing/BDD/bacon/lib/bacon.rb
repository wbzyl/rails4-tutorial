class Bacon

  attr_accessor :expired

  # def self.edible?
  #   true
  # end

  def edible?
    # !expired
    not expired
    # true
  end

  def expired!
    self.expired = true
  end

end
