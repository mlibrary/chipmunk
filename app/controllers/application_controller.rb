# frozen_string_literal: true

require 'policy_errors'

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # Add a before_action to authenticate all requests.
  # Move this to subclassed controllers if you only
  # want to authenticate certain methods.
  before_action :authenticate
  before_action :set_format_to_json

  rescue_from NotAuthorizedError, with: :user_not_authorized

  attr_reader :current_user

  def fake_user(user)
    @current_user = user if Rails.env.test?
  end

  protected

  def user_not_authorized
    head 403
  end

  def set_format_to_json
    request.format = :json
  end

  # Authenticate the user with token based authentication
  def authenticate
    return if @current_user && Rails.env.test?
    if request.has_header?('HTTP_AUTHORIZATION')
      authenticate_token
    elsif request.has_header?('HTTP_X_REMOTE_USER')
      authenticate_remote_user
    else
      redirect_to("/login")
    end
  end

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      @current_user = User.find_by(api_key: token) || render_unauthorized
    end
  end

  def authenticate_remote_user
    @current_user = User.new
    @current_user.email = "#{request.get_header('HTTP_X_REMOTE_USER')}@umich.edu"
  end

  def render_unauthorized(realm = "Application")
    headers["WWW-Authenticate"] = %(Token realm="#{realm.delete('"')}")
    render json: "Bad credentials", status: :unauthorized
  end

end
