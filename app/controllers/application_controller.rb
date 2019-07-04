# frozen_string_literal: true

require "policy_errors"

class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  # It's unclear why this is required. The include is ignoring the config
  # option, which is false under test, so we have to apply it by hand.
  self.allow_forgery_protection = ActionController::Base.allow_forgery_protection

  include Keycard::ControllerMethods

  # Add before_action to authenticate and secure all requests.
  # If an API key is provided, it must also be valid. We do not fall back
  # to other forms of authentication in the case of failure.
  # If it isn't provided, attempt to find the user via the user_eid, or
  # build out a guest user.
  # Skip authenticate! for specific actions if you want to bypass the requirement.
  # TODO: Add config option to allow nonmember users, reject them, or autocreate them
  before_action :validate_session
  before_action :authenticate!
  protect_from_forgery with: :exception, unless: -> { authentication.csrf_safe? }
  before_action :set_csrf_cookie

  before_action :set_format_to_json

  rescue_from Keycard::AuthenticationRequired, with: :redirect_to_login
  rescue_from Keycard::AuthenticationFailed, with: :authentication_failed
  rescue_from ActionController::InvalidAuthenticityToken, with: :user_not_authorized
  rescue_from NotAuthorizedError, with: :user_not_authorized
  rescue_from Chipmunk::FileNotFoundError, with: :file_not_found

  def fallback_index_html
    app_index = "public/index.html"
    if File.exist?(Rails.root.join(app_index))
      render file "public/index.html", content_type: :html
    elsif Rails.env.development?
      render plain: "Frontend application is not built in public/. Only the API is available."
    else
      file_not_found
    end
  end

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

  def set_csrf_cookie
    cookies["CSRF-TOKEN"] = form_authenticity_token
  end

  def session_timeout
    Chipmunk.config.session_timeout
  end

  def notary
    Services.notary
  end
end
