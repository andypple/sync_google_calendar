# frozen_string_literal: true

class TokenRefresher < BaseService
  def initialize(user)
    super
    @user = user
  end

  def call
    return if (user.expires_at - 1.minute).future?

    TokenGateway.new.refresh(user.refresh_token).then { |result| user.update(result) }
  end

  private

  attr_reader :user
end
