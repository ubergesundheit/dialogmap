class Feature < ActiveRecord::Base
  set_rgeo_factory_for_column(:geom, RGeo::Geographic.spherical_factory(:srid => 4326))
  attr_accessor :geojson

  before_validation :params_to_geojson

  validates :geojson, presence: true
  #validates :geom, presence: true

  def geojson_string
    RGeo::GeoJSON.encode(self.geom)
  end

  def as_json(*args)
    super.tap { |hash| hash['geojson'] = RGeo::GeoJSON.encode(hash.delete['geom']) }
  end

  private
    def params_to_geojson
      #binding.pry
      self.geom = RGeo::GeoJSON.decode(self.geojson, :json_parser => :json)
      self.errors.add(:geojson, "invalid GeoJSON") unless self.geom
    end

end
