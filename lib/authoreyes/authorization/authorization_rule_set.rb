module Authoreyes
  module Authorization
    class AuthorizationRuleSet
      include Enumerable
      extend Forwardable
      def_delegators :@rules, :each, :length, :[]

      def initialize(rules = [])
        @rules = rules.clone
        reset!
      end

      def initialize_copy(source)
        @rules = @rules.collect {|rule| rule.clone}
        reset!
      end

      def matching(roles, privileges, context)
        roles = [roles] unless roles.is_a?(Array)
        rules = cached_auth_rules[context] || []
        rules.select do |rule|
          rule.matches? roles, privileges, context
        end
      end

      def delete(rule)
        @rules.delete rule
        reset!
      end

      def << rule
        @rules << rule
        reset!
      end

      def each(&block)
        @rules.each &block
      end

      private
      def reset!
        @cached_auth_rules =nil
      end

      def cached_auth_rules
        return @cached_auth_rules if @cached_auth_rules
        @cached_auth_rules = {}
        @rules.each do |rule|
          rule.contexts.each do |context|
            @cached_auth_rules[context] ||= []
            @cached_auth_rules[context] << rule
          end
        end
        @cached_auth_rules
      end
    end
  end
end
