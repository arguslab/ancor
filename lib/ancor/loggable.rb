module Ancor
  # Mixin that provides uniform log access
  #
  # @example
  #   class AwesomeSauceProvider
  #     include Loggable
  #
  #     def provide_the_sauce
  #       logger.debug 'Providing awesome-sauce'
  #     end
  #   end
  module Loggable
    extend ActiveSupport::Concern

    private

    def logger
      Ancor.logger
    end
  end # Loggable
end
