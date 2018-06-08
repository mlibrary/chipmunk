# frozen_string_literal: true

class UsersController < ApplicationController
  def login
    if session[:return_to]
      redirect_to session[:return_to]
      session.delete(:return_to)
    else
      redirect_to "/v1/packages"
    end
  end
end
