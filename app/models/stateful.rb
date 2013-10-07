module Stateful
  extend ActiveSupport::Concern
  include Mongoid::Document

  # Atomic compare and swap of the document state
  #
  # @param [Symbol] new_state
  # @return [Boolean] True if state was updated
  def update_state(new_state)
    criteria = {
      :id => id,
      :state => state
    }

    update = {
      "$set" => { :state => new_state }
    }

    if self.class.where(criteria).find_and_modify(update)
      reload
      true
    else
      false
    end
  end
end
