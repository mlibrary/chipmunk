# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Chipmunk.config.default_from
  layout "mailer"
end
