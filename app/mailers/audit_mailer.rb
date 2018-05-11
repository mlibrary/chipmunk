class AuditMailer < ApplicationMailer
  def failure(emails: [], package:, error:)
    @error = error
    mail(
      to: emails | [package.user.email],
      subject: "Dark Blue Audit Failure for #{package.content_type} package #{package.external_id}")
  end


end
