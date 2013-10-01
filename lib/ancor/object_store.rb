module Ancor
  # Represents a mechanism for storing arbitrary chunks of content for later use
  class ObjectStore
    include AbstractType

    # Returns true if an object with the given identifier exists in this store
    #
    # @param [String] identifier
    # @return [Boolean]
    abstract_method :exists?

    # Returns the content of an object in this store by its identifier
    #
    # @raise [KeyError] If object does not exist
    # @param [String] identifier
    # @return [String]
    abstract_method :fetch

    # Stores the given content in this store and returns an identifier that
    # can be used to access it later
    #
    # @param [String] content
    # @return [String]
    abstract_method :put
  end # ObjectStore
end
