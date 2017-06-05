

# Given a hash of parameters, this builds a request of an
# appropriate type. It does the following:
#
# Contacts third-party services to ensure metadata is present and accurate.
# Provisions a location for the file to be uploaded
# Populates the upload_link field of the request
#
# This process is synchronous.
class RequestBuilder
  def initialize(bag_id:, content_type:, external_id:, user:)
    @request = klass_for(content_type)
      .new(
        bag_id: bag_id,
        external_id: external_id,
        user: user
      )
  end

  def create
    request.save!
    request
  end

  def klass_for(content_type)
    case content_type
    when "audio"
      AudioRequest
    when "digital"
      DigitalRequest
    else
      raise ArgumentError, "Unknown content type #{content_type} for request"
    end
  end

  private

  attr_accessor :request
end
