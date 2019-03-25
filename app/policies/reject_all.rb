# frozen_string_literal: true

# A dummy policy that accepts any constructor arguments, answers any predicate
# method with false, and always raises and error on authorize!
class RejectAll
  # Accept anything, discard everything
  def initialize(*_args)
  end

  # Always answer false for predicates; pass anything else up the chain
  # to raise standard NoMethodError.
  def method_missing(action, *_args, &_block)
    if action.to_s.ends_with('?')
      false
    else
      super
    end
  end

  def respond_to_missing?(action, include_private = false)
    action.to_s.ends_with('?') || super
  end

  def authorize!(action, message = "#{action} not authorized (RejectAll)")
    raise NotAuthorizedError, message
  end
end
