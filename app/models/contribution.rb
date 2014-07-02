require 'color'
class Contribution < ActiveRecord::Base
  has_many :features
  has_many :references

  belongs_to :parent, :class_name => "Contribution"
  has_many :child_contributions, :foreign_key => "parent_id", :class_name => "Contribution", dependent: :destroy

  accepts_nested_attributes_for :features, reject_if: :features_exist
  accepts_nested_attributes_for :references, reject_if: :references_exist

  validates_presence_of :description, :user_id, :category, :activity, :content

  before_save :lighten_features_colors, if: :about_to_be_deleted?

  after_save :transform_description

  after_save :update_category_activity_content

  default_scope { order('created_at ASC') }

  scope :within, -> (bbox_string) {
    where(id: Feature.within(bbox_string).map { |f| f.contribution_id })
  }

  scope :only_parents, -> { where(parent: nil) }

  # returns categories as cat because of the hstore_accessor gem I am using..
  scope :categories, -> {
    unscoped
    .select("DISTINCT ON (cat) (properties -> 'category') AS cat, (properties -> 'category_color') AS cat_col")
    .map{ |c|
      {
        id: c.cat,
        text: c.cat,
        color: c.cat_col
      } unless c.cat == nil
    }.compact
  }

  scope :activities, -> {
    unscoped
    .select("DISTINCT ON (act) (properties -> 'activity') AS act, (properties -> 'activity_icon') AS icon")
    .map{ |a|
      {
        id: a.act,
        text: a.act,
        icon: a.icon
      } unless a.act == nil
    }.compact
  }

  scope :contents, -> {
    unscoped
    .select("DISTINCT ON (con) (properties -> 'content') AS con")
    .map{ |c|
      c.con.split('||;||')
      .map{ |cc| { id: cc, text: cc } } unless c.con == nil
    }.flatten.uniq
  }

  hstore_accessor :properties,
    category: :string,
    category_color: :string,
    activity: :string,
    activity_icon: :string,
    content: :array

  def user
    User.find(self.user_id)
  end

  # def children_ids
  #   self.children_contributions.map { |c| c.merge(c.children_ids) }
  # end

  private

    def about_to_be_deleted?
      self.deleted
    end

    def lighten_features_colors
      self.features.each { |f| f.lighten_colors }
    end

    def references_exist(reference_attr)
      if reference_attr["id"]
        id = reference_attr["id"]
        reference = self.references.find(id)
        unless reference == nil
          reference.update(reference_attr)
          true
        end
        false
      else
        false
      end
    end

    def features_exist(feature_attr)
      if feature_attr["geojson"] != nil and feature_attr["geojson"]["properties"] != nil and feature_attr["geojson"]["properties"]["id"] != nil
        id = feature_attr["geojson"]["properties"]["id"]
        feature = self.features.find(id)
        unless feature == nil
          feature.update_from_geojson(feature_attr["geojson"])
          true
        else
          false
        end
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

    def update_category_activity_content
      # Update child contributions
      if self.category_changed?
        self.child_contributions
          .update_all([%(properties = properties || hstore('category',?)),
                       self.category])
      end
      if self.activity_changed?
        self.child_contributions
          .update_all([%(properties = properties || hstore('activity',?)),
                       self.activity])
      end
      if self.content_changed?
        self.child_contributions
          .update_all([%(properties = properties || hstore('content',?)),
                       self.content.join("||;||")])
      end
      # Update the color of all Contributions with the same category
      Contribution
        .unscoped
        .with_category(self.category)
        .update_all([%(properties = properties || hstore('category_color',?)),
                     self.category_color])
      Contribution
        .unscoped
        .with_activity(self.activity)
        .update_all([%(properties = properties || hstore('activity_icon',?)),
                     self.activity_icon])

      deleted_color = Color::RGB.by_hex(self.category_color).lighten_by(65).html
      # Update deleted Markers
      Feature
        .where("contribution_id IN (?) AND defined(properties,'marker-color') = 't'",
               Contribution.unscoped.with_category(self.category).where(deleted: true).select(:id))
        .update_all([%(properties = properties || hstore('marker-color', ?)),
          deleted_color])
      # Update deleted Polygons
      Feature
        .where("contribution_id IN (?) AND defined(properties,'stroke') = 't' AND defined(properties,'fill') = 't'",
               Contribution.unscoped.with_category(self.category).where(deleted: true).select(:id))
        .update_all([%(properties = properties || hstore(ARRAY['stroke','fill'], ARRAY[?,?])),
          deleted_color,
          deleted_color])
      # Update Markers
      Feature
        .where("contribution_id IN (?) AND defined(properties,'marker-color') = 't'",
               Contribution.unscoped.with_category(self.category).where(deleted: false).select(:id))
        .update_all([%(properties = properties || hstore('marker-color', ?)),
          self.category_color])
      # Update the icon of Markers
      Feature
        .where("contribution_id IN (?) AND defined(properties,'marker-symbol') = 't'",
               Contribution.unscoped.with_activity(self.activity).select(:id))
        .update_all([%(properties = properties || hstore('marker-symbol', ?)),
          self.activity_icon])
      # Update Polygons
      Feature
        .where("contribution_id IN (?) AND defined(properties,'stroke') = 't' AND defined(properties,'fill') = 't'",
               Contribution.unscoped.with_category(self.category).where(deleted: false).select(:id))
        .update_all([%(properties = properties || hstore(ARRAY['stroke','fill'], ARRAY[?,?])),
          self.category_color,
          self.category_color])
    end

end
