# frozen_string_literal: true

require "json"
require "open-uri"
require "uri"

class Chipmunk::Bag
  class Profile

    def initialize(uri)
      uri = URI.parse(uri)
      profile = if uri.scheme == "file"
        File.read(uri.path)
      else
        uri.read
      end

      @tags = JSON.parse(profile)["ordered"].map {|t| Tag.from_hash(t) }
    end

    def valid?(bag_info, errors: [])
      tags.map {|tag| tag.value_valid?(bag_info[tag.name], errors: errors) }.all? {|valid| valid == true }
    end

    private

    attr_reader :tags
  end
end
