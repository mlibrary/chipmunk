# frozen_string_literal: true

class PackagePolicy < ResourcePolicy

  def show?
    user&.admin? || resource&.user == user
  end
end
