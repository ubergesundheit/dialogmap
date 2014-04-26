class Contribution < ActiveRecord::Base
  has_many :features

  accepts_nested_attributes_for :features
end
