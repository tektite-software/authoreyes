module Authoreyes
  module Parser
    # Top-level reader, parses the methods +privileges+ and +authorization+.
    # +authorization+ takes a block with authorization rules as described in
    # AuthorizationRulesReader.  The block to +privileges+ defines privilege
    # hierarchies, as described in PrivilegesReader.
    #
    class DSLParser
      attr_reader :privileges_reader, :auth_rules_reader # :nodoc:

      def initialize
        @privileges_reader = PrivilegesReader.new
        @auth_rules_reader = AuthorizationRulesParser.new
      end

      def initialize_copy (from) # :nodoc:
        @privileges_reader = from.privileges_reader.clone
        @auth_rules_reader = from.auth_rules_reader.clone
      end

      # ensures you get back a DSLReader
      # if you provide a:
      #   DSLReader - you will get it back.
      #   String or Array - it will treat it as if you have passed a path
      #     or an array of paths and attempt to load those.
      def self.factory(obj)
        case obj
        when Parser::DSLParser
          obj
        when String, Array
          load(obj)
        end
      end

      # Parses an authorization DSL specification from the string given
      # in +dsl_data+.  Raises DSLSyntaxError if errors occur on parsing.
      def parse(dsl_data, file_name = nil)
        if file_name
          DSLMethods.new(self).instance_eval(dsl_data, file_name)
        else
          DSLMethods.new(self).instance_eval(dsl_data)
        end
        rescue SyntaxError, NoMethodError, NameError => e
          raise DSLSyntaxError, "Illegal DSL syntax: #{e}"
      end

      # Load and parse a DSL from the given file name.
      def load(dsl_file)
        parse(File.read(dsl_file), dsl_file) if File.exist?(dsl_file)
      end

      # Load and parse a DSL from the given file name. Raises
      # Authorization::Reader::DSLFileNotFoundError
      # if the file cannot be found.
      def load!(dsl_file)
        raise ::Authoreyes::Parser::DSLFileNotFoundError, "Error reading authorization rules file with path '#{dsl_file}'!  Please ensure it exists and that it is accessible." unless File.exist?(dsl_file)
        load(dsl_file)
      end

      # Loads and parses DSL files and returns a new reader
      def self.load(dsl_files)
        # TODO cache reader in production mode?
        reader = new
        dsl_files = [dsl_files].flatten
        dsl_files.each do |file|
          reader.load(file)
        end
        reader
      end

      # DSL methods
      class DSLMethods # :nodoc:
        def initialize(parent)
          @parent = parent
        end

        def privileges(&block)
          @parent.privileges_reader.instance_eval(&block)
        end

        def contexts(&block)
          # Not implemented
        end

        def authorization(&block)
          @parent.auth_rules_reader.instance_eval(&block)
        end
      end
    end
  end
end
