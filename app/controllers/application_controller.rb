# frozen_string_literal: true

require "policy_errors"

class ApplicationController < ActionController::API
  include Keycard::ControllerMethods

  # Add a before_action to authenticate all requests.
  # Skip this filter for specific actions if you want to bypass the requirement.
  # If an API key is provided, it must also be valid. We do not fall back
  # to other forms of authentication in the case of failure.
  # If it isn't provided, attempt to find the user via the user_eid, or
  # build out a guest user.
  # TODO: Add config option to allow nonmember users, reject them, or autocreate them
  before_action :authenticate!

  before_action :set_format_to_json

  rescue_from Keycard::AuthenticationRequired, with: :redirect_to_login
  rescue_from Keycard::AuthenticationFailed, with: :authentication_failed
  rescue_from NotAuthorizedError, with: :user_not_authorized
  rescue_from Chipmunk::FileNotFoundError, with: :file_not_found

  def fake_user(user)
    raise "only for testing" unless Rails.env.test?

    user.identity ||= {}
    auto_login(user)
  end

  protected

  def user_not_authorized
    head 403
  end

  def file_not_found
    head 404
  end

  def set_format_to_json
    request.format = :json
  end

  def render_unauthorized(realm = "Application")
    headers["WWW-Authenticate"] = %(Token realm="#{realm.delete('"')}")
    render json: { error: "Bad credentials" }, status: :unauthorized
  end

  def redirect_to_login
    if request.get? && !request.xhr?
      session[:return_to] = request.path
      redirect_to login_path
    else
      render_unauthorized
    end
  end

  def authentication_failed
    render_unauthorized
  end

  def notary
    Services.notary
  end
end
