class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :confirmed

  def confirmed
    object.confirmed?
  end
end
