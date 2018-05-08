class AuditMailer < ApplicationMailer
  def failure(audit: nil, package:, error:)
    @error = error
    mail(to: [audit.user.email, package.user.email], subject: "Dark Blue Audit Failure for #{package.content_type} package #{package.external_id}")
  end
end
