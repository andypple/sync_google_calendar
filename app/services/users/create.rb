# frozen_string_literal: true

module Users
  class Create < BaseService
    def initialize(auth)
      super(auth)

      @auth = auth.with_indifferent_access
    end

    def call
      return unless google_oauth2?

      set_user
      update_credentails
      user
    end

    private

    attr_reader :auth, :user

    GOOGLE_PROVIDER = 'google_oauth2'

    def google_oauth2?
      auth[:provider] == GOOGLE_PROVIDER
    end

    def set_user
      password = Devise.friendly_token[0, 8]
      @user = User.create_with(
        password: password, password_confirmation: password
      ).find_or_create_by(email: email)
    end

    def email
      auth.dig(:info, :email)
    end

    def update_credentails
      user.update(
        token: auth.dig(:credentials, :token),
        refresh_token: auth.dig(:credentials, :refresh_token),
        expires_at: Time.zone.at(auth.dig(:credentials, :expires_at))
      )
    end
  end
end
