module Authoreyes
  module Authorization
    # An attribute condition that uses existing rules to decide validation
    # and create obligations.
    class AttributeWithPermission < Attribute
      # E.g. privilege :read, attr_or_hash either :attribute or
      # { :attribute => :deeper_attribute }
      def initialize(privilege, attr_or_hash, context = nil)
        @privilege = privilege
        @context = context
        @attr_hash = attr_or_hash
      end

      def initialize_copy(_from)
        @attr_hash = deep_hash_clone(@attr_hash) if @attr_hash.is_a?(Hash)
      end

      def validate?(attr_validator, object = nil, hash_or_attr = nil)
        object ||= attr_validator.object
        hash_or_attr ||= @attr_hash
        return false unless object

        case hash_or_attr
        when Symbol
          attr_value = object_attribute_value(object, hash_or_attr)
          case attr_value
          when nil
            raise NilAttributeValueError, "Attribute #{hash_or_attr.inspect} is nil in #{object.inspect}."
          when Enumerable
            attr_value.any? do |inner_value|
              attr_validator.engine.permit? @privilege, object: inner_value, user: attr_validator.user
            end
          else
            attr_validator.engine.permit? @privilege, object: attr_value, user: attr_validator.user
          end
        when Hash
          hash_or_attr.all? do |attr, sub_hash|
            attr_value = object_attribute_value(object, attr)
            if attr_value.nil?
              raise NilAttributeValueError, "Attribute #{attr.inspect} is nil in #{object.inspect}."
            elsif attr_value.is_a?(Enumerable)
              attr_value.any? do |inner_value|
                validate?(attr_validator, inner_value, sub_hash)
              end
            else
              validate?(attr_validator, attr_value, sub_hash)
            end
          end
        when NilClass
          attr_validator.engine.permit? @privilege, object: object, user: attr_validator.user
        else
          raise AuthorizationError, "Wrong conditions hash format: #{hash_or_attr.inspect}"
        end
      end

      # may return an array of obligations to be OR'ed
      def obligation(attr_validator, hash_or_attr = nil, path = [])
        hash_or_attr ||= @attr_hash
        case hash_or_attr
        when Symbol
          @context ||= begin
            rule_model = attr_validator.context.to_s.classify.constantize
            context_reflection = self.class.reflection_for_path(rule_model, path + [hash_or_attr])
            if context_reflection.klass.respond_to?(:decl_auth_context)
              context_reflection.klass.decl_auth_context
            else
              context_reflection.klass.name.tableize.to_sym
            end
          rescue # missing model, reflections
            hash_or_attr.to_s.pluralize.to_sym
          end

          obligations = attr_validator.engine.obligations(@privilege,
                                                          context: @context,
                                                          user: attr_validator.user)

          obligations.collect { |obl| { hash_or_attr => obl } }
        when Hash
          obligations_array_attrs = []
          obligations =
            hash_or_attr.inject({}) do |all, pair|
              attr, sub_hash = pair
              all[attr] = obligation(attr_validator, sub_hash, path + [attr])
              if all[attr].length > 1
                obligations_array_attrs << attr
              else
                all[attr] = all[attr].first
              end
              all
            end
          obligations = [obligations]
          obligations_array_attrs.each do |attr|
            next_array_size = obligations.first[attr].length
            obligations = obligations.collect do |obls|
              (0...next_array_size).collect do |idx|
                obls_wo_array = obls.clone
                obls_wo_array[attr] = obls_wo_array[attr][idx]
                obls_wo_array
              end
            end.flatten
          end
          obligations
        when NilClass
          attr_validator.engine.obligations(@privilege,
                                            context: attr_validator.context,
                                            user: attr_validator.user)
        else
          raise AuthorizationError, "Wrong conditions hash format: #{hash_or_attr.inspect}"
        end
      end

      def to_long_s
        "if_permitted_to #{@privilege.inspect}, #{@attr_hash.inspect}"
      end

      private

      def self.reflection_for_path(parent_model, path)
        reflection = path.empty? ? parent_model : begin
          parent = reflection_for_path(parent_model, path[0..-2])
          if !parent.respond_to?(:proxy_reflection) && parent.respond_to?(:klass)
            parent.klass.reflect_on_association(path.last)
          else
            parent.reflect_on_association(path.last)
          end
        rescue
          parent.reflect_on_association(path.last)
        end
        raise "invalid path #{path.inspect}" if reflection.nil?
        reflection
      end
    end
  end
end
