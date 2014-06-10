class Contribution < ActiveRecord::Base
  has_many :features
  has_many :references

  belongs_to :parent, :class_name => "Contribution"
  has_many :child_contributions, :foreign_key => "parent_id", :class_name => "Contribution"

  accepts_nested_attributes_for :features, reject_if: :features_exist
  accepts_nested_attributes_for :references

  validates_presence_of :description, :user_id

  after_save :transform_description

  default_scope { order('created_at ASC') }

  scope :within, -> (bbox_string) {
    where(id: Feature.within(bbox_string).map { |f| f.contribution_id })
  }

  scope :only_parents, -> { where(parent: nil) }

  def user
    User.find(self.user_id)
  end

  # def children_ids
  #   self.children_contributions.map { |c| c.merge(c.children_ids) }
  # end

  private

    def features_exist(feature_attr)
      if feature_attr["geojson"] != nil and feature_attr["geojson"]["properties"] != nil and feature_attr["geojson"]["properties"]["id"] != nil
        id = feature_attr["geojson"]["properties"]["id"]
        feature = self.features.find(id)
        unless feature == nil
          feature.update_from_geojson(feature_attr["geojson"])
        end
        true
      else
        false
      end
    end

    def transform_description
      # when creating contributions, the description contains references to
      # features that don't exist yet..

      # create a hash that contains the substitutions
      substitutions = self.features.map { |f| [ "%[#{f.leaflet_id}]%", "%[#{f.id}]%" ]}.to_h
      # substitute..
      self.save if self.description.gsub! Regexp.new("%\\[(#{self.features.map { |f| f.leaflet_id }.join('|')})\\]%"), substitutions
    end

end
