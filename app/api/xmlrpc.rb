module Api
  module XmlRpc

    class NamespaceNotDefinedError < StandardError
      attr_reader :klass

      def initialize(klass)
        @klass = klass
        message = "Uknown XMLRCP namespace for #{ klass }. Make sure to assign value using `self.namespace = 'value'`"

        super(message)
      end
    end

    class UnauthorizedError < StandardError
      def initialize
        message = "User is not authorized to perform this action."

        super(message)
      end
    end

    @@klasses = []

    def validate_user!(username, password)
      unless username == ENV["USERNAME"].to_s && password == ENV["PASSWORD"].to_s
        raise UnauthorizedError.new
      end
    end

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
