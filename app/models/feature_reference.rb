class FeatureReference < Reference

  def reference_to
    Feature.find(self.ref_id)
  end

end
