class ApplicationController < ActionController::Base
  def serialize(resource, option = {})
    result = ::ActiveModelSerializers::SerializableResource.new(
      resource,
      option
    ).serializable_hash.as_json

    if result.is_a?(Hash)
      result.deep_transform_keys! { |key| key.camelize(:lower) }
    else
      result.map { |item| item.deep_transform_keys! { |key| key.camelize(:lower) } }
    end
  end
end
