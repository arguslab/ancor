module Ancor
  module Provisioning
    # @abstract
    class Resource
      include Operational

      def self.document_type
        @document_type
      end

      def self.map_document(document_type)
        @document_type = document_type
      end

      ######

      attr_reader :id
      attr_reader :document

      def initialize(id)
        @id = id

        begin
          @document = self.class.document_type.find id
        rescue Mongoid::Errors::Document
          ## Don't worry about this until ensuring the state
        end
      end

      def ensure(state)
        case state
        when :present
          if exists?
            update
          else
            create
          end
        when :absent
          if exists?
            destroy
          end
        end
      end

      def exists?
      end

      def create
      end

      def destroy
      end

      def update
      end
    end # Resource
  end # Provisioning
end
