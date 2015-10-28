require 'simple_router'

module Api
  module Json
    @@klasses = []
    @@routes = SimpleRouter::Routes.new

    def self.routes
      @@routes
    end

    def self.included(klass)
      @@klasses << klass
      klass.send(:extend, SimpleRouter::DSL::ClassMethods)
      klass.send(:extend, ClassMethods)
    end

    def self.implementations
      @@klasses.map do |klass|
        { klass: klass }
      end
    end

    module ClassMethods
      def routes
        Api::Json.routes
      end
    end
  end
end
