class Feature < ActiveRecord::Base
  # see api.rubyonrails.org/classes/ActiveRecord/ModelSchema/ClassMethods.html#method-i-inheritance_column
  self.inheritance_column = 'inheritance_column'
  set_rgeo_factory_for_column(:geom, RGeo::Geographic.spherical_factory(:srid => 4326))
  attr_accessor :geojson
  attr_accessor :feature_id
  hstore_accessor :properties, #simplestyle-spec github.com/mapbox/simplestyle-spec
    :title            => :string,
    :description      => :string,
    :"marker-size"    => :string,
    :"marker-symbol"  => :string,
    :"marker-color"   => :string,
    :stroke           => :string,
    :"stroke-opacity" => :float,
    :"stroke-width"   => :float,
    :fill             => :string,
    :"fill-opacity"   => :float

  before_validation :decode_geojson_from_params, if: :geojson_present?

  scope :within, -> (bbox_string) {
    bbox_array = bbox_string.split(",")
    factory = rgeo_factory_for_column(:geom)
    sw = factory.point(bbox_array[0], bbox_array[1])
    ne = factory.point(bbox_array[2], bbox_array[3])
    window = RGeo::Cartesian::BoundingBox.create_from_points(sw, ne).to_geometry
    where("geom && ?", window)
  }

  def attributes
    {
      'id' => nil,
      'type' => nil,
      'geometry' => nil,
      'properties' => nil
    }
  end

  def geometry
    RGeo::GeoJSON.encode(self.geom)
  end

  # overwritten
  def type
    'Feature'
  end

  # augment the properties hash for better handling
  def properties
    props = super
    props.merge! :contribution_id => self.contribution_id unless props.has_key? :contribution_id
    props.merge! :id => self.id unless props.has_key? :id
    props
  end

  private
    def decode_geojson_from_params
      geojson = RGeo::GeoJSON.decode(self.geojson, :json_parser => :json)
      self.geom = geojson.geometry
      self.properties = geojson.properties
      self.errors.add(:geojson, "invalid GeoJSON") unless self.geom
    end

    def geojson_present?
      self.geojson != nil
    end

end
