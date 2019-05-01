# frozen_string_literal: true

class Chipmunk::Bag
  class Validator
    include Chipmunk::Validatable

    attr_reader :errors

    # TODO: Decide exactly what this should take... Package, Bag, or what?
    # @param package [Package]
    # @param bag [Chipmunk::Package] If nil, the bag does not yet exist.
    def initialize(package, errors = [], bag = nil)
      @package = package
      @src_path = package.src_path
      @bag = bag
      @errors = errors
    end

    validates "bag must exist on disk at src_path",
      condition: -> { File.exist?(src_path) },
      error: -> { "Bag does not exist at upload location #{src_path}" }

    validates "bag on disk must be valid",
      condition: -> { bag.valid? },
      error: -> { "Error validating bag:\n" + indent_array(bag.errors.full_messages) }

    { "External-Identifier"   => :external_id,
      "Bag-ID"                => :bag_id,
      "Chipmunk-Content-Type" => :content_type }.each_pair do |file_key, db_key|
        validates "#{file_key} in bag on disk matches bag in database",
          precondition: -> { [bag.chipmunk_info[file_key], package.public_send(db_key)] },
          condition:  ->(file_val, db_val) { file_val == db_val },
          error: lambda {|file_val, db_val|
            "uploaded #{file_key} '#{file_val}'" \
                  " does not match expected value '#{db_val}'"
          }
      end

    validates "Bag ID in bag on disk matches bag in database",
      condition:  -> { bag.chipmunk_info["Bag-ID"] == package.bag_id },
      error: lambda {
        "uploaded Bag-ID '#{bag.chipmunk_info["Bag-ID"]}'" \
            " does not match intended ID '#{package.bag_id}'"
      }

    metadata_tags = ["Metadata-URL", "Metadata-Type", "Metadata-Tagfile"]

    validates "chipmunk-info.txt has metadata tags",
      error: -> { "Some (but not all) metadata tags #{metadata_tags} missing in chipmunk-info.txt" },
      condition: lambda {
        metadata_tags.all? {|tag| bag.chipmunk_info.key?(tag) } ||
          metadata_tags.none? {|tag| bag.chipmunk_info.key?(tag) }
      }

    validates "bag on disk has referenced metadata files",
      only_if: -> { bag.chipmunk_info["Metadata-Tagfile"] },
      error: -> { "Missing referenced metadata #{bag.chipmunk_info["Metadata-Tagfile"]}" },
      condition: lambda {
        bag.tag_files.map {|f| File.basename(f) }
          .include?(bag.chipmunk_info["Metadata-Tagfile"])
      }

    validates "bag on disk passes external validation",
      only_if: -> { package.external_validation_cmd },
      precondition: -> { Open3.capture3(package.external_validation_cmd) },
      condition: ->(_, _, status) { status.exitstatus.zero? },
      error: ->(_, stderr, _) { "Error validating content\n" + stderr }

    validates "bag on disk meets bagger profile",
      only_if: -> { package.bagger_profile },
      condition: -> { Profile.new(package.bagger_profile).valid?(bag.bag_info, errors: errors) },
      error: -> { "Not valid according to bagger profile" }

    private

    def indent_array(array, width = 2)
      array.map {|s| " " * width + s }.join("\n")
    end

    attr_reader :src_path, :package, :bag
  end
end
