module Authoreyes
  module Authorization
    class AuthorizationRule
      attr_reader :attributes, :contexts, :role, :privileges, :join_operator,
                  :source_file, :source_line

      def initialize(role, privileges = [], contexts = nil, join_operator = :or,
                     options = {})
        @role = role
        @privileges = Set.new(privileges)
        @contexts = Set.new((contexts && !contexts.is_a?(Array) ? [contexts] : contexts))
        @join_operator = join_operator
        @attributes = []
        @source_file = options[:source_file]
        @source_line = options[:source_line]
      end

      def initialize_copy(_from)
        @privileges = @privileges.clone
        @contexts = @contexts.clone
        @attributes = @attributes.collect(&:clone)
      end

      def append_privileges(privs)
        @privileges.merge(privs)
      end

      def append_attribute(attribute)
        @attributes << attribute
      end

      def matches?(roles, privs, context = nil)
        roles = [roles] unless roles.is_a?(Array)
        @contexts.include?(context) && roles.include?(@role) &&
          !(@privileges & privs).empty?
      end

      def validate?(attr_validator, skip_attribute = false)
        skip_attribute || @attributes.empty? ||
          @attributes.send(@join_operator == :and ? :all? : :any?) do |attr|
            begin
              attr.validate?(attr_validator)
            rescue NilAttributeValueError => e
              nil # Bumping up against a nil attribute value flunks the rule.
            end
          end
      end

      def obligations(attr_validator)
        exceptions = []
        obligations = @attributes.collect do |attr|
          begin
            attr.obligation(attr_validator)
          rescue NotAuthorized => e
            exceptions << e
            nil
          end
        end

        if !exceptions.empty? && (@join_operator == :and || exceptions.length == @attributes.length)
          raise NotAuthorized, "Missing authorization in collecting obligations: #{exceptions.map(&:to_s) * ', '}"
        end

        if @join_operator == :and && !obligations.empty?
          # cross product of OR'ed obligations in arrays
          arrayed_obligations = obligations.map { |obligation| obligation.is_a?(Hash) ? [obligation] : obligation }
          merged_obligations = arrayed_obligations.first
          arrayed_obligations[1..-1].each do |inner_obligations|
            previous_merged_obligations = merged_obligations
            merged_obligations = inner_obligations.collect do |inner_obligation|
              previous_merged_obligations.collect do |merged_obligation|
                merged_obligation.deep_merge(inner_obligation)
              end
            end.flatten
          end
          obligations = merged_obligations
        else
          obligations = obligations.flatten.compact
        end
        obligations.empty? ? [{}] : obligations
      end

      def to_long_s
        attributes.collect(&:to_long_s) * '; '
      end
    end
  end
end
