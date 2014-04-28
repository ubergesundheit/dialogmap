class Contribution < ActiveRecord::Base
  has_many :features

  accepts_nested_attributes_for :features

  validates_presence_of :title, :description, :features

  scope :within, -> (bbox_string) {
    where(id: Feature.within(bbox_string).map { |f| f.contribution_id })
  }
end
