# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def alfred
      @user = User.from_omniauth(auth.provider, auth.uid, alfred_info)

      if @user.valid?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Alfred') if is_navigational_format?
      else
        session['devise.alfred_data'] = auth.except('extra')
        redirect_to new_user_session_path, alert: @user.errors.full_messages.join("\n")
      end
    end

    def google
      @user = User.from_omniauth(auth.provider, auth.uid, auth.info)

      if @user.valid?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
      else
        session['devise.google_data'] = auth.except('extra')
        redirect_to new_user_session_path, alert: @user.errors.full_messages.join("\n")
      end
    end

    def facebook
      @user = User.from_omniauth(auth.provider, auth.uid, auth.info)

      if @user.valid?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
      else
        session['devise.facebook_data'] = auth.except('extra')
        redirect_to new_user_session_path, alert: @user.errors.full_messages.join("\n")
      end
    end

    def developer
      @user = User.first

      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Developer') if is_navigational_format?
    end

    def failure
      redirect_to new_user_session_path
    end

    private

    def auth
      request.env['omniauth.auth']
    end

    def alfred_info
      {
        email: auth.info.email,
        image: auth.info.avatar_url,
        nickname: auth.info.nickname,
        first_name: auth.info.first_name,
        last_name: auth.info.last_name
      }
    end
  end
end
