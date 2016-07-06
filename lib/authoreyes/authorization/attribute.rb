module Authoreyes
  module Authorization
    class Attribute
      # attr_conditions_hash of form
      # { :object_attribute => [operator, value_block], ... }
      # { :object_attribute => { :attr => ... } }
      def initialize (conditions_hash)
        @conditions_hash = conditions_hash
      end

      def initialize_copy (from)
        @conditions_hash = deep_hash_clone(@conditions_hash)
      end

      def validate? (attr_validator, object = nil, hash = nil)
        object ||= attr_validator.object
        return false unless object

        if ( Authorization.is_a_association_proxy?(object) &&
             object.respond_to?(:empty?) )
          return false if object.empty?
          object.each do |member|
            return true if validate?(attr_validator, member, hash)
          end
          return false
        end

        (hash || @conditions_hash).all? do |attr, value|
          attr_value = object_attribute_value(object, attr)
          if value.is_a?(Hash)
            if attr_value.is_a?(Enumerable)
              attr_value.any? do |inner_value|
                validate?(attr_validator, inner_value, value)
              end
            elsif attr_value == nil
              raise NilAttributeValueError, "Attribute #{attr.inspect} is nil in #{object.inspect}."
            else
              validate?(attr_validator, attr_value, value)
            end
          elsif value.is_a?(Array) and value.length == 2 and value.first.is_a?(Symbol)
            evaluated = if value[1].is_a?(Proc)
                          attr_validator.evaluate(value[1])
                        else
                          value[1]
                        end
            case value[0]
            when :is
              attr_value == evaluated
            when :is_not
              attr_value != evaluated
            when :contains
              begin
                attr_value.include?(evaluated)
              rescue NoMethodError => e
                raise AuthorizationUsageError, "Operator contains requires a " +
                    "subclass of Enumerable as attribute value, got: #{attr_value.inspect} " +
                    "contains #{evaluated.inspect}: #{e}"
              end
            when :does_not_contain
              begin
                !attr_value.include?(evaluated)
              rescue NoMethodError => e
                raise AuthorizationUsageError, "Operator does_not_contain requires a " +
                    "subclass of Enumerable as attribute value, got: #{attr_value.inspect} " +
                    "does_not_contain #{evaluated.inspect}: #{e}"
              end
            when :intersects_with
              begin
                !(evaluated.to_set & attr_value.to_set).empty?
              rescue NoMethodError => e
                raise AuthorizationUsageError, "Operator intersects_with requires " +
                    "subclasses of Enumerable, got: #{attr_value.inspect} " +
                    "intersects_with #{evaluated.inspect}: #{e}"
              end
            when :is_in
              begin
                evaluated.include?(attr_value)
              rescue NoMethodError => e
                raise AuthorizationUsageError, "Operator is_in requires a " +
                    "subclass of Enumerable as value, got: #{attr_value.inspect} " +
                    "is_in #{evaluated.inspect}: #{e}"
              end
            when :is_not_in
              begin
                !evaluated.include?(attr_value)
              rescue NoMethodError => e
                raise AuthorizationUsageError, "Operator is_not_in requires a " +
                    "subclass of Enumerable as value, got: #{attr_value.inspect} " +
                    "is_not_in #{evaluated.inspect}: #{e}"
              end
            when :lt
              attr_value && attr_value < evaluated
            when :lte
              attr_value && attr_value <= evaluated
            when :gt
              attr_value && attr_value > evaluated
            when :gte
              attr_value && attr_value >= evaluated
            else
              raise AuthorizationError, "Unknown operator #{value[0]}"
            end
          else
            raise AuthorizationError, "Wrong conditions hash format"
          end
        end
      end

      # resolves all the values in condition_hash
      def obligation (attr_validator, hash = nil)
        hash = (hash || @conditions_hash).clone
        hash.each do |attr, value|
          if value.is_a?(Hash)
            hash[attr] = obligation(attr_validator, value)
          elsif value.is_a?(Array) and value.length == 2
            hash[attr] = [value[0], attr_validator.evaluate(value[1])]
          else
            raise AuthorizationError, "Wrong conditions hash format"
          end
        end
        hash
      end

      def to_long_s (hash = nil)
        if hash
          hash.inject({}) do |memo, key_val|
            key, val = key_val
            memo[key] = case val
                        when Array then "#{val[0]} { #{val[1].respond_to?(:to_ruby) ? val[1].to_ruby.gsub(/^proc \{\n?(.*)\n?\}$/m, '\1') : "..."} }"
                        when Hash then to_long_s(val)
                        end
            memo
          end
        else
          "if_attribute #{to_long_s(@conditions_hash).inspect}"
        end
      end

      protected
      def object_attribute_value (object, attr)
        begin
          object.send(attr)
        rescue ArgumentError, NoMethodError => e
          raise AuthorizationUsageError, "Error occurred while validating attribute ##{attr} on #{object.inspect}: #{e}.\n" +
            "Please check your authorization rules and ensure the attribute is correctly spelled and \n" +
            "corresponds to a method on the model you are authorizing for."
        end
      end

      def deep_hash_clone (hash)
        hash.inject({}) do |memo, (key, val)|
          memo[key] = case val
                      when Hash
                        deep_hash_clone(val)
                      when NilClass, Symbol
                        val
                      else
                        val.clone
                      end
          memo
        end
      end
    end
  end
end
