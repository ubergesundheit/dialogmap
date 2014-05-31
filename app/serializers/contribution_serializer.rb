class ContributionSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :title, :description, :parent_id, :created_at,
    :updated_at, :references
    has_many :features, :child_contributions
    has_one :user

  def references
    object.references.as_json(include: :reference_to)
  end

end