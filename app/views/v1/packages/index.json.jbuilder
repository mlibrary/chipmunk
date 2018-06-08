# frozen_string_literal: true

json.partial! "v1/packages/package", expand: false, collection: @packages, as: :package
