# frozen_string_literal: true

# Filter an ActiveRecord::Relation (or similar) to a set of Resources for which
# the actor has a {:show} permission granted.
#
# This is implemented by finding resource tokens for which the actor has some
# credential granting {:show}, then mapping the tokens to conventional resource
# scopes and then reducing them with `.or` for the conceptual equivalent of:
#
#   SELECT * FROM Resource WHERE id IN <scope A> OR id IN <scope B>
#
# The relation must implement:
#
#   #all, #with_type(type), and #with_type_and_id(type, id), #resource_types
#
class ViewableResources
  attr_reader :actor, :relation

  # @param actor The user or other entity listing resources
  # @param relation The resource relation (model/scope) to filter
  # @param authority [Checkpoint::Authority] The authority to consult
  def initialize(actor:, relation:, authority:)
    @actor = actor
    @relation = relation
    @authority = authority
  end

  # Create a ViewableResources filter for an actor and relation and execute it
  # immediately. This is a convenience factory that binds in the default
  # authority and runs {.all}.
  #
  # @example Setting a policy's base scope with minimal ceremony
  #   def base_scope
  #     ViewableResources.for(user, SomeModel.all)
  #   end
  #
  # @return [Relation] the relation filtered to accessible resources
  def self.for(actor, relation, authority: Services.checkpoint)
    new(actor: actor, relation: relation, authority: authority).all
  end

  def all
    if authorized_scopes.empty?
      relation.none
    else
      authorized_scopes.reduce(:or)
    end
  end

  private

  def authorized_scopes
    @authorized_scopes ||= authority
      .which(actor, :show)
      .select {|token| token.all? || relation.resource_types.include?(token.type) }
      .map {|token| scope_for_resource(token) }
  end

  def scope_for_resource(token)
    if token.all?
      relation.all
    elsif token.all_of_type?
      relation.with_type(token.type)
    else
      relation.with_type_and_id(token.type, token.id)
    end
  end

  attr_reader :authority
end
