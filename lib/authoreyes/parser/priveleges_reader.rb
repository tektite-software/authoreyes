module Authoreyes
  module Parser
    # The PrivilegeReader handles the part of the authorization DSL in
    # a +privileges+ block.  Here, privilege hierarchies are defined.
    class PrivilegesReader
      # TODO: handle privileges with separated context
      attr_reader :privileges, :privilege_hierarchy # :nodoc:

      def initialize # :nodoc:
        @current_privelege = nil
        @current_context = nil
        @privileges = []
        # {priv => [[priv,ctx], ...]}
        @privilege_hierarchy = {}
      end

      def initialize_copy(from) # :nodoc:
        @privileges = from.privileges.clone
        @privilege_hierarchy = from.privilege_hierarchy.clone
      end

      def append_privilege(priv) # :nodoc:
        @privileges << priv unless @privileges.include?(priv)
      end

      # Defines part of a privilege hierarchy.  For the given +privilege+,
      # included privileges may be defined in the block (through includes)
      # or as option :+includes+.  If the optional context is given,
      # the privilege hierarchy is limited to that context.
      #
      def privilege(privilege, context = nil, options = {}, &block)
        if context.is_a?(Hash)
          options = context
          context = nil
        end
        @current_privelege = privilege
        @current_context = context
        append_privilege privilege
        instance_eval(&block) if block
        includes(*options[:includes]) if options[:includes]
      ensure
        @current_privelege = nil
        @current_context = nil
      end

      # Specifies +privileges+ that are to be assigned as lower ones.  Only to
      # be used inside a privilege block.
      def includes(*privileges)
        raise DSLError,
              'includes only in privilege block' if @current_privelege.nil?
        privileges.each do |priv|
          append_privilege priv
          @privilege_hierarchy[@current_privelege] ||= []
          @privilege_hierarchy[@current_privelege] << [priv, @current_context]
        end
      end
    end
  end
end
