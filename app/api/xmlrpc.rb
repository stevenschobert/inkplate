module Api
  module XMLRPC

    class NamespaceNotDefinedError < StandardError
      attr_reader :klass

      def initialize(klass)
        @klass = klass
        message = "Uknown XMLRCP namespace for #{ klass }. Make sure to assign value using `self.namespace = 'value'`"

        super(message)
      end
    end

    @@klasses = []

    def self.included(klass)
      @@klasses << klass
      klass.send(:extend, ClassMethods)
    end

    def self.implementations
      @@klasses.map do |klass|
        unless namespace = klass.namespace
          raise NamespaceNotDefinedError.new(klass)
        end

        { namespace: namespace, klass: klass }
      end
    end

    module ClassMethods
      def namespace=(value)
        @namespace = value
      end

      def namespace
        @namespace
      end
    end

  end
end
