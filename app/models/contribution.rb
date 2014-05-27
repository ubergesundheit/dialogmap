class Contribution < ActiveRecord::Base
  has_many :features
  has_many :references

  belongs_to :parent, :class_name => "Contribution"
  has_many :children_contributions, :foreign_key => "parent_id", :class_name => "Contribution"

  accepts_nested_attributes_for :features, :references

  validates_presence_of :description, :user_id

  after_create :transform_description

  scope :within, -> (bbox_string) {
    where(id: Feature.within(bbox_string).map { |f| f.contribution_id })
  }

  def user
    User.find(self.user_id)
  end

  # def children_ids
  #   self.children_contributions.map { |c| c.merge(c.children_ids) }
  # end

  private
    def transform_description
      # when creating contributions, the description contains references to
      # features that don't exist yet..

      # create a hash that contains the substitutions
      substitutions = self.features.map { |f| [ "%[#{f.leaflet_id}]%", "%[#{f.id}]%" ]}.to_h
      #substitute..
      self.description.gsub! /%\[\d+\]%/, substitutions
      self.save
    end

end
