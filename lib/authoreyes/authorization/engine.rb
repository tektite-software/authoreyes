module Authoreyes
  module Authorization
    # Authorization::Engine implements the reference monitor.  It may be used
    # for querying the permission and retrieving obligations under which
    # a certain privilege is granted for the current user.
    class Engine
      extend Forwardable
      attr_reader :reader

      def_delegators :@reader, :auth_rules_reader, :privileges_reader, :load, :load!
      def_delegators :auth_rules_reader, :auth_rules, :roles, :omnipotent_roles, :role_hierarchy, :role_titles, :role_descriptions
      def_delegators :privileges_reader, :privileges, :privilege_hierarchy

      # If +reader+ is not given, a new one is created with the default
      # authorization configuration of +AUTH_DSL_FILES+.  If given, may be either
      # a Reader object or a path to a configuration file.
      def initialize(options)
        options = {
          reader: nil
        }.merge(options)
        # @auth_rules = AuthorizationRuleSet.new reader.auth_rules_reader.auth_rules
        @reader = ::Authoreyes::Parser::DSLParser.factory(options[:reader] || AUTH_DSL_FILES)
      end

      def initialize_copy(from) # :nodoc:
        @reader = from.reader.clone
      end

      # {[priv, ctx] => [priv, ...]}
      def rev_priv_hierarchy
        if @rev_priv_hierarchy.nil?
          @rev_priv_hierarchy = {}
          privilege_hierarchy.each do |key, value|
            value.each do |val|
              @rev_priv_hierarchy[val] ||= []
              @rev_priv_hierarchy[val] << key
            end
          end
        end
        @rev_priv_hierarchy
      end

      # {[priv, ctx] => [priv, ...]}
      def rev_role_hierarchy
        if @rev_role_hierarchy.nil?
          @rev_role_hierarchy = {}
          role_hierarchy.each do |higher_role, lower_roles|
            lower_roles.each do |role|
              (@rev_role_hierarchy[role] ||= []) << higher_role
            end
          end
        end
        @rev_role_hierarchy
      end

      # Returns true if privilege is met by the current user.  Raises
      # AuthorizationError otherwise.  +privilege+ may be given with or
      # without context.  In the latter case, the :+context+ option is
      # required.
      #
      # Options:
      # [:+context+]
      #   The context part of the privilege.
      #   Defaults either to the tableized +class_name+ of the given :+object+, if given.
      #   That is, :+users+ for :+object+ of type User.
      #   Raises AuthorizationUsageError if context is missing and not to be inferred.
      # [:+object+] An context object to test attribute checks against.
      # [:+skip_attribute_test+]
      #   Skips those attribute checks in the
      #   authorization rules. Defaults to false.
      # [:+user+]
      #   The user to check the authorization for.
      #   Defaults to Authorization#current_user.
      # [:+bang+]
      #   Should NotAuthorized exceptions be raised
      #   Defaults to true.
      #
      def permit!(privilege, options = {})
        return true if Authorization.ignore_access_control
        options = {
          object: nil,
          skip_attribute_test: false,
          context: nil,
          bang: true
        }.merge(options)

        # Make sure we're handling all privileges as symbols.
        privilege = privilege.is_a?(Array) ?
                    privilege.flatten.collect(&:to_sym) :
                    privilege.to_sym

        # Convert context to symbol as well
        unless options[:context].nil?
          options[:context] = options[:context].to_sym
        end

        #
        # If the object responds to :proxy_reflection, we're probably working with
        # an association proxy.  Use 'new' to leverage ActiveRecord's builder
        # functionality to obtain an object against which we can check permissions.
        #
        # Example: permit!( :edit, :object => user.posts )
        #
        if Authorization.is_a_association_proxy?(options[:object]) && options[:object].respond_to?(:new)
          options[:object] = (Rails.version < '3.0' ? options[:object] : options[:object].where(nil)).new
        end

        begin
          options[:context] ||= options[:object] && (
                    options[:object].class.respond_to?(:decl_auth_context) ?
                        options[:object].class.decl_auth_context :
                        options[:object].class.name.tableize.to_sym
          )
        rescue
          NoMethodError
        end

        user, roles, privileges = user_roles_privleges_from_options(privilege, options)

        return true if roles.is_a?(Array) && !(roles & omnipotent_roles).empty?

        # find a authorization rule that matches for at least one of the roles and
        # at least one of the given privileges
        attr_validator = AttributeValidator.new(self, user, options[:object], privilege, options[:context])
        rules = matching_auth_rules(roles, privileges, options[:context])

        # Test each rule in turn to see whether any one of them is satisfied.
        rules.each do |rule|
          return true if rule.validate?(attr_validator, options[:skip_attribute_test])
        end

        if options[:bang]
          if rules.empty?
            raise NotAuthorized, "No matching rules found for #{privilege} for #{user.inspect} " \
                                 "(roles #{roles.inspect}, privileges #{privileges.inspect}, " \
                                 "context #{options[:context].inspect})."
          else
            raise AttributeAuthorizationError, "#{privilege} not allowed for #{user.inspect} on #{(options[:object] || options[:context]).inspect}."
          end
        else
          false
        end
      end

      # Calls permit! but doesn't raise authorization errors. If no exception is
      # raised, permit? returns true and yields  to the optional block.
      def permit?(privilege, options = {}) # :yields:
        if permit!(privilege, options.merge(bang: false))
          yield if block_given?
          true
        else
          false
        end
      end

      # Returns the obligations to be met by the current user for the given
      # privilege as an array of obligation hashes in form of
      #   [{:object_attribute => obligation_value, ...}, ...]
      # where +obligation_value+ is either (recursively) another obligation hash
      # or a value spec, such as
      #   [operator, literal_value]
      # The obligation hashes in the array should be OR'ed, conditions inside
      # the hashes AND'ed.
      #
      # Example
      #   {:branch => {:company => [:is, 24]}, :active => [:is, true]}
      #
      # Options
      # [:+context+]  See permit!
      # [:+user+]  See permit!
      #
      def obligations(privilege, options = {})
        options = { context: nil }.merge(options)
        user, roles, privileges = user_roles_privleges_from_options(privilege, options)

        permit!(privilege, skip_attribute_test: true, user: user, context: options[:context])

        return [] if roles.is_a?(Array) && !(roles & omnipotent_roles).empty?

        attr_validator = AttributeValidator.new(self, user, nil, privilege, options[:context])
        matching_auth_rules(roles, privileges, options[:context]).collect do |rule|
          rule.obligations(attr_validator)
        end.flatten
      end

      # Returns the description for the given role.  The description may be
      # specified with the authorization rules.  Returns +nil+ if none was
      # given.
      def description_for(role)
        role_descriptions[role]
      end

      # Returns the title for the given role.  The title may be
      # specified with the authorization rules.  Returns +nil+ if none was
      # given.
      def title_for(role)
        role_titles[role]
      end

      # Returns the role symbols of the given user.
      def roles_for(user)
        user ||= Authorization.current_user
        raise AuthorizationUsageError, "User object doesn't respond to roles (#{user.inspect})" \
          if !user.respond_to?(:role_symbols) && !user.respond_to?(:roles)

        Rails.logger.info('The use of user.roles is deprecated.  Please add a method ' \
            'role_symbols to your User model.') if defined?(Rails) && Rails.respond_to?(:logger) && !user.respond_to?(:role_symbols)

        roles = user.respond_to?(:role_symbols) ? user.role_symbols : user.roles

        raise AuthorizationUsageError, "User.#{user.respond_to?(:role_symbols) ? 'role_symbols' : 'roles'} " \
                                       "doesn't return an Array of Symbols (#{roles.inspect})" \
              if !roles.is_a?(Array) || (!roles.empty? && !roles[0].is_a?(Symbol))

        (roles.empty? ? [Authorization.default_role] : roles)
      end

      # Returns the role symbols and inherritted role symbols for the given user
      def roles_with_hierarchy_for(user)
        flatten_roles(roles_for(user))
      end

      def self.development_reload?
        if Rails.env.development?
          mod_time = AUTH_DSL_FILES.map do |m|
            begin
                                     File.mtime(m)
                                   rescue
                                     Time.at(0)
                                   end
          end.flatten.max
          @@auth_dsl_last_modified ||= mod_time
          if mod_time > @@auth_dsl_last_modified
            @@auth_dsl_last_modified = mod_time
            return true
          end
        end
      end

      # Returns an instance of Engine, which is created if there isn't one
      # yet.  If +dsl_file+ is given, it is passed on to Engine.new and
      # a new instance is always created.
      def self.instance(dsl_file = nil)
        if dsl_file || development_reload?
          @@instance = new(dsl_file)
        else
          @@instance ||= new
        end
      end

      class AttributeValidator # :nodoc:
        attr_reader :user, :object, :engine, :context, :privilege
        def initialize(engine, user, object = nil, privilege = nil, context = nil)
          @engine = engine
          @user = user
          @object = object
          @privilege = privilege
          @context = context
        end

        def evaluate(value_block)
          # TODO: cache?
          instance_eval(&value_block)
        end
      end

      private

      def user_roles_privleges_from_options(privilege, options)
        options = {
          user: nil,
          context: nil,
          user_roles: nil
        }.merge(options)
        user = options[:user] || Authorization.current_user
        privileges = privilege.is_a?(Array) ? privilege : [privilege]

        raise AuthorizationUsageError, "No user object given (#{user.inspect}) or " \
                                       'set through Authorization.current_user' unless user

        roles = options[:user_roles] || flatten_roles(roles_for(user))
        privileges = flatten_privileges privileges, options[:context]
        [user, roles, privileges]
      end

      def flatten_roles(roles, flattened_roles = Set.new)
        # TODO: caching?
        roles.reject { |role| flattened_roles.include?(role) }.each do |role|
          flattened_roles << role
          flatten_roles(role_hierarchy[role], flattened_roles) if role_hierarchy[role]
        end
        flattened_roles.to_a
      end

      # Returns the privilege hierarchy flattened for given privileges in context.
      def flatten_privileges(privileges, context = nil, flattened_privileges = Set.new)
        # TODO: caching?
        raise AuthorizationUsageError, 'No context given or inferable from object' unless context
        privileges.reject { |priv| flattened_privileges.include?(priv) }.each do |priv|
          flattened_privileges << priv
          flatten_privileges(rev_priv_hierarchy[[priv, nil]], context, flattened_privileges) if rev_priv_hierarchy[[priv, nil]]
          flatten_privileges(rev_priv_hierarchy[[priv, context]], context, flattened_privileges) if rev_priv_hierarchy[[priv, context]]
        end
        flattened_privileges.to_a
      end

      def matching_auth_rules(roles, privileges, context)
        auth_rules.matching(roles, privileges, context)
      end
    end
  end
end
