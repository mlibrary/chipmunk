# frozen_string_literal: true

require "policy_errors"
require "file_errors"

class ApplicationController < ActionController::API

  # Add a before_action to authenticate all requests.
  # Move this to subclassed controllers if you only
  # want to authenticate certain methods.
  before_action :authenticate
  before_action :set_format_to_json

  rescue_from NotAuthorizedError, with: :user_not_authorized
  rescue_from FileNotFoundError, with: :file_not_found

  attr_reader :current_user

  def fake_user(user)
    raise "only for testing" unless Rails.env.test?

    @current_user = user
    @current_user.identity ||= {}
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

  def authenticate
    # If an API key is provided, it must also be valid. We do not fall back
    # to other forms of authentication.
    # If it isn't provided, attempt to find the user via the user_eid, or
    # build out a guest user.
    return if @current_user && Rails.env.test?

    request_attributes = Services.request_attributes.for(request)
    if request_attributes.auth_token
      authenticate_token(request_attributes)
    else
      authenticate_nontoken(request_attributes)
    end
  end

  def authenticate_token(request_attributes)
    digest = Keycard::DigestKey.new(key: request_attributes.auth_token).digest
    if (@current_user = User.find_by(api_key_digest: digest))
      @current_user.identity = { username: @current_user.username }
    else
      render_unauthorized
    end
  end

  def authenticate_nontoken(request_attributes)
    @current_user = User.find_by(username: request_attributes.user_eid)
    @current_user ||= User.new
    @current_user.username ||= request_attributes.user_eid
    @current_user.identity = request_attributes.identity
    @current_user.identity[:username] = @current_user.username
    unless @current_user.identity[:username]
      if request.get? && !request.xhr?
        session[:return_to] = request.path
        redirect_to("/login")
      else
        # redirecting to an interactive login page isn't a good idea with POST
        # or non-interactive (XMLHttpRequest) requests - cribbed from Sorcery
        render_unauthorized
      end
    end
  end

  def render_unauthorized(realm = "Application")
    headers["WWW-Authenticate"] = %(Token realm="#{realm.delete('"')}")
    render json: "Bad credentials", status: :unauthorized
  end

end
