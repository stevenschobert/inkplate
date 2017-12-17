module Api
  class System

    include XmlRpc

    self.namespace = "system"

    def listMethods
      methods = XmlRpc.implementations.map do |impl|
        {
          namespace: impl[:namespace],
          methods: impl[:klass].public_instance_methods(false)
        }
      end
      methods = methods.reduce([]) do |acc, impl|
        impl[:methods].each do |method|
          acc << "#{ impl[:namespace] }.#{ method.to_s }"
        end
        acc
      end
      methods
    end

  end
end
