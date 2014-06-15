class ContributionSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :parent_id, :created_at,
    :updated_at, :references, :deleted, :delete_reason
    has_many :features, :child_contributions
    has_one :user

  def references
    object.references.as_json(include: :reference_to)
  end

end
