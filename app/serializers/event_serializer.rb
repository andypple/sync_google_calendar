class EventSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :gid, :start, :end, :description
  attribute :summary, key: :title
end
