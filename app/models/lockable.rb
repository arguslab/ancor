module Lockable
  extend ActiveSupport::Concern
  include Mongoid::Document

  IllegalLockUsageError = Class.new RuntimeError
  LockAcquisitionError = Class.new RuntimeError

  included do
    field :locked_by, default: false
  end

  def synchronized
    lock

    begin
      yield
    ensure
      unlock
    end
  end

  # @raise [LockAcquisitionError] If lock could not be acquired
  # @return [Lockable]
  def lock
    raise LockAcquisitionError unless cas_locked_by(Process.pid)
    self
  end

  # @return [Boolean]
  def locked?
    !!locked_by
  end

  # @raise [IllegalLockUsageError] If lock was not held
  # @return [Lockable]
  def unlock
    raise IllegalLockUsageError unless locked?

    self.locked_by = false
    save
  end

  private

  # Atomic compare and swap of the lock field
  #
  # @param [Object] value
  # @return [Boolean] True if the operation was successful
  def cas_locked_by(value)
    criteria = {
      id: id,
      locked_by: false
    }

    update = {
      "$set" => { locked_by: value }
    }

    result = self.class.where(criteria).find_and_modify(update)
    reload

    result
  end
end
