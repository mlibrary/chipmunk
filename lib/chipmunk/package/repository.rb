# frozen_string_literal: true

class Chipmunk::Package
  # Primary interface for finding and storing packages.
  class Repository
    # Create a Package Repository.
    #
    # @param adapters: [Hash<Symbol, Storage>] a map of formats to storage
    #   adapters to register; equivalent to registering each individually
    def initialize(adapters: {})
      @adapters = {}
      adapters.each do |format, adapter|
        register format, adapter
      end
    end

    # Find a specific package in the repository.
    #
    # @param format: [Symbol] the format of package to find
    # @param id: [String] the id of the package to find
    # @raise [Chipmunk::UnsupportedFormatError] if there is no storage adapter
    #   for the specified format
    # @raise [Chipmunk::PackageNotFoundError] if there is no package of the
    #   given format with the given id
    # @return [Chipmunk::Package] the package from the repository, bound to storage
    # TODO: Work through the descriptor notion here... Specific concerns:
    #       1. If IDs in the repository can be unique across formats, id may suffice.
    #       2. The Package model currently holds absolute paths; some of that
    #          responsibility belongs here or at the storage level, regardless
    #          of whether it goes in a table in the same database.
    #       3. There are at least three kinds of identifiers in play already;
    #          what is the right one (or set) to be usable at the package
    #          repository and storage levels?
    #       4. The Storage interface now is using the term ID with the notion that
    #          the identifiers would be directly resolvable (by string manipulation
    #          only) to storage locations, but implementations may need to be wired
    #          up with a collaborator that can do a lookup, at least in transition.
    def find(format:, id:)
      unsupported_format!(format) unless supports?(format)

      adapters[format.to_sym].get(id).tap do |package|
        not_found!(format, id) if package.nil?
      end
    end

    # Register a storage adapter for a given package format.
    #
    # @param format [Symbol|String] the format identifier for the adapter; coerced to Symbol
    # @param adapter [Storage] the storage adapter that manages this format
    def register(format, adapter)
      adapters[format.to_sym] = adapter
    end

    # Check whether a given format is supported by this package repository.
    #
    # @param format [Symbol|String] the format to test; coerced to Symbol
    # @return [Boolean] true when there is a registered adapter for the named
    #   format; false otherwise
    def supports?(format)
      adapters.has_key? format.to_sym
    end

    private

    def not_found!(format, id)
      raise Chipmunk::PackageNotFoundError, "Package of type '#{format}' not found with id: #{id}"
    end

    def unsupported_format!(format)
      raise Chipmunk::UnsupportedFormatError, "Package Repository does not support format: #{format}"
    end

    attr_reader :adapters
  end
end
