class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :confirmed, :external_auth

  def confirmed
    object.confirmed?
  end

  def external_auth
    Identity.where(user_id: object.id).count != 0
  end
end
