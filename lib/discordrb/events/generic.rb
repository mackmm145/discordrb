require 'active_support/core_ext/module'

module Discordrb::Events
  class Negated
    attr_reader :object
    def initialize(object); @object = object; end
  end

  def self.matches_all(attributes, to_check, &block)
    # "Zeroth" case: attributes is nil
    return true unless attributes

    # First case: there's a single negated attribute
    if attributes.is_a? Negated
      # The contained object might also be an array, so recursively call matches_all (and negate the result)
      return !matches_all(attributes.object, to_check, &block)
    end

    # Second case: there's a single, not-negated attribute
    unless attributes.is_a? Array
      return yield(attributes, to_check)
    end

    # Third case: it's an array of attributes
    attributes.reduce(false) do |result, element|
      result || yield(element, to_check)
    end
  end

  class EventHandler
    def initialize(attributes, block)
      @attributes = attributes
      @block = block
    end

    def matches?(event)
      raise "Attempted to call matches?() from a generic EventHandler"
    end

    def match(event)
      @block.call(event) if matches? event
    end

    def matches_all(attributes, to_check, &block)
      Discordrb::Events.matches_all(attributes, to_check, &block)
    end
  end

  # Event handler that matches all events
  class TrueEventHandler < EventHandler
    def matches?(event)
      true
    end
  end
end

def not!(object)
  Discordrb::Events::Negated.new(object)
end
