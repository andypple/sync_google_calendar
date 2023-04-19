class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: %i[google_oauth2 failure]

  def google_oauth2
    @user = Users::Create.new(auth).call

    if @user.present?
      sign_in(@user)
      SyncCalendarJob.perform_later(@user.id)

      redirect_to root_path
    else
      render_unauthenticated
    end
  end

  def failure
    redirect_to new_user_session_url
  end

  private

  def render_unauthenticated
    session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
    redirect_to new_user_session_url
  end

  def auth
    request.env['omniauth.auth']
  end
end
