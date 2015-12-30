class SessionSerializer < ActiveModel::Serializer
  attributes(
    :username,
    :password
  )
end
