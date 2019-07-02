# frozen_string_literal: true

class LoginController < ApplicationController
  skip_before_action :authenticate!

  def new
    if login
      redirect_back_or_to "/"
    elsif Chipmunk.config.allow_impersonation && !request.xhr?
      render plain: login_form, content_type: "text/html"
    else
      render_unauthorized
    end
  end

  def create
    return forbidden! unless Chipmunk.config.allow_impersonation

    username = params[:username]
    user = User.find_by_username(username)
    if user
      auto_login(user)
      redirect_back_or_to "/"
    else
      render_unauthorized
    end
  end

  def destroy
    logout
    redirect_back_or_to "/"
  end

  private

  def redirect_back_or_to(destination)
    destination = session[:return_to] || destination || "/"
    session.delete(:return_to)
    redirect_to destination
  end

  def forbidden!
    head 403
  end

  def login_form
    <<~FORM
      <html>
        <body>
          <form method="post">
            <input type="text" name="username" />
            <input type="submit" name="login" />
          </form>
        </body>
      </html>
    FORM
  end
end
