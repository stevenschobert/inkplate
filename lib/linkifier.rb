require "erb"

class Linkifier

  class HashContext
    def initialize(hash)
      hash.each do |key, val|
        instance_variable_set("@#{ key }".to_sym, val)
      end

      @binding = binding
    end

    def context
      @binding
    end
  end

  class Formatter
    def initialize(fmt, params)
      @format_string = fmt
      @format_params = params
    end

    def format
      context = HashContext.new(format_params)
      builder = ERB.new(format_string)

      builder.result(context.context)
    end

    private

    def format_string
      @format_string || ""
    end

    def format_params
      @format_params || {}
    end
  end

  def self.link(object)
    self.new().link(object)
  end

  def link(object)
    fmt = link_format_for(object)

    case object
    when ActiveRecord::Base
      Formatter.new(fmt, object.attributes).format
    else
      Formatter.new(fmt, object: object).format
    end
  end

  private

  def link_format_for(object)
    key_postfix = object.try(:kind) || object.class.to_s
    key = "LINK_FORMAT_#{ key_postfix.upcase }"
    fallback = "LINK_FORMAT_DEFAULT"
    ENV[key] || ENV[fallback]
  end

end
