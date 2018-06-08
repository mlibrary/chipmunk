# frozen_string_literal: true

require 'policy_errors'
require 'user_attributes'
require 'file_errors'

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

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

  # Authenticate the user with token based authentication
  def authenticate
    return if @current_user && Rails.env.test?
    if request.has_header?('HTTP_AUTHORIZATION')
      authenticate_token
    else
      authenticate_keycard
    end

  end

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      if @current_user = User.find_by(api_key: token)
        @current_user.identity = UserAttributes.new(username: @current_user.username)
      else
        render_unauthorized
      end
    end
  end

  def authenticate_keycard
    @current_user = User.new
    @current_user.identity = Keycard::RequestAttributes.new(request)
    if @current_user.identity[:username].empty?
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
