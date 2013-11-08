module Lockable
  extend ActiveSupport::Concern
  include Mongoid::Document

  IllegalLockUsageError = Class.new RuntimeError
  LockAcquisitionError = Class.new RuntimeError

  included do
    field :locked, default: false
    field :locked_by, default: false
  end

  # @raise [LockAcquisitionError] If lock could not be acquired
  # @param [String] key
  # @return [Lockable]
  def lock(key)
    unless update_locked(false, key.to_s)
      raise LockAcquisitionError
    end

    self.locked_by = Process.pid
    save
  end

  def locked?(key)
    locked == key.to_s
  end

  # @raise [IllegalLockUsageError] If lock was not held by the given key
  # @param [String] key
  # @return [Lockable]
  def unlock(key)
    unless locked == key.to_s
      raise IllegalLockUsageError
    end

    self.locked = false
    self.locked_by = false

    save
  end

  private

  # Atomic compare and swap of the lock field
  #
  # @param [Object] expected
  # @param [Object] value
  # @return [Boolean] True if the operation was successful
  def update_locked(expected, value)
    criteria = {
      :id => id,
      :locked => expected
    }

    update = {
      "$set" => { :locked => value }
    }

    if self.class.where(criteria).find_and_modify(update)
      reload
      true
    else
      false
    end
  end
end
