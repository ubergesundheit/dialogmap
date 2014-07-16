class ContributionSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :parent_id, :created_at,
    :updated_at, :references, :deleted, :delete_reason, :category, :activity,
    :content, :start_date, :end_date, :favorites, :image_url, :features
    has_many :child_contributions
    has_one :user

  def references
    object.references.as_json(include: :reference_to)
  end

  def features
    (object.features.as_json + object.references.map { |r| r.reference_to }).uniq
  end

  def category
    { id: object.category, text: object.category, color: object.category_color }
  end

  def activity
    { id: object.activity, text: object.activity, icon: object.activity_icon }
  end

  def content
    object.content.map{ |c| { id: c, text: c } } unless object.content == nil
  end

  def image_url
    object.image.url
  end

end
