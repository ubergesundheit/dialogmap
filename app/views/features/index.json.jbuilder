json.array!(@features) do |feature|
  json.extract! feature, :id, :geom
  json.url feature_url(feature, format: :json)
end
