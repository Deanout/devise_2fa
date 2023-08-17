# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    redirect_to edit_registration_path(resource_name) and return if should_disable_otp? && !disable_otp!

    process_standard_update
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:otp_attempt])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  def should_disable_otp?
    resource.otp_required_for_login && params[:user][:otp_attempt].present? && params[:user][:current_password].present?
  end

  def disable_otp!
    otp_attempt = params[:user][:otp_attempt]
    current_password = params[:user][:current_password]

    if resource.validate_and_consume_otp!(otp_attempt) && resource.valid_password?(current_password)
      resource.otp_required_for_login = false
      resource.save!
      set_flash_message!(:notice, :otp_disabled)
      true
    else
      set_flash_message!(:alert, appropriate_error_message(otp_attempt, current_password))
      false
    end
  end

  def appropriate_error_message(otp_attempt, current_password)
    return :invalid_otp unless resource.validate_and_consume_otp!(otp_attempt)
    return :invalid_password unless resource.valid_password?(current_password)

    :invalid_otp_and_password
  end

  def process_standard_update
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?

    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

end
