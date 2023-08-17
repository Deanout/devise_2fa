# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    # Authenticate user with just email and password.
    self.resource = warden.authenticate!(auth_options.merge(strategy: :password_authenticatable))

    if resource && resource.active_for_authentication?
      # If the user has 2FA enabled
      if resource.otp_required_for_login
        # Store the user ID temporarily. We're not saving the password in the session for security reasons.
        # Generate a signed token for the user ID.
        verifier = Rails.application.message_verifier(:otp_session)
        token = verifier.generate(resource.id)
        session[:otp_token] = token

        # Logout the user to wait for the 2FA verification
        sign_out(resource_name)

        # Redirect the user to the OTP entry page
        redirect_to user_otp_path and return
      else
        # If 2FA is not required, log the user in
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        yield resource if block_given?
        respond_with resource, location: after_sign_in_path_for(resource) and return
      end
    end

    # If user authentication failed
    flash[:alert] = 'Invalid email or password.'
    redirect_to new_user_session_path
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
