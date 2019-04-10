# frozen_string_literal: true

module ChipmunkPathname
  def type
    Rack::Mime.mime_type(extname)
  end
end

unless Pathname.pwd.respond_to?(:type)
  Pathname.include ChipmunkPathname
end
