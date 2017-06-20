module Authoreyes
  module Helpers
    module InUser
      module InstanceMethods
        # +guest_privileges_on+
        # Returns a hash of booleans for each privelege the user has on the
        # object or context passed in.
        # Call on an authenticated user and pass in any resource or
        # authorization context.
        #
        # ==== Examples
        #
        #   # Example Authorization Rules
        #   authorization do
        #     role :user do
        #       has_permission_on :example_objects, to: [:create, :read]
        #     end
        #   end
        #
        #   current_user.privileges_on(@example_object)
        #   # => { index: true, show: true, create: true, update: false, delete: false }
        def privileges_on(object)
          result = {}
          engine = Authoreyes::ENGINE
          privileges = engine.privileges
          privileges.each do |e|
            result.merge! e => engine.permit?(e, object: object, user: self)
          end
          result
        end

        # Returns an array of symbols for each role the User has.  This is a
        # convenience method designed to automatically try different common
        # ways you might have Roles set up in your app.  You may experience
        # better performance by overriding this method in your User model,
        # even if you use case is covered here.
        def role_symbols
          # Handle cases when User likely has multiple roles
          if self.respond_to?(:roles)
            # If +roles+ appears to be a has_many relationship,
            # try making the role_symbols array with the title
            # and name keys.  Otherwise raise an error.
            if roles.kind_of?(ActiveRecord::Relation)
              if roles.first.respond_to?(:title)
                return roles.map { |r| r.title.to_sym }
              elsif roles.first.respond_to?(:name)
                return roles.map { |r| r.name.to_sym }
              else
                raise RoleInterpolationError
              end
            # If +roles+ is an Array, assume it make be a mix of various
            # data types (strings, symbols, classes, etc) and attempt to
            # return the elements as uniformly formatted symbols.
            elsif roles.kind_of?(Array)
              begin
                return roles.map { |r| r.to_s.underscore.downcase.to_sym }
              rescue StandardError => error
                puts "ERROR: #{error}"
                raise RoleInterpolationError
              end
            else
              raise RoleInterpolationError
            end
          # Handle cases when User likely has a single role
          elsif self.respond_to?(:role)
            # If Role is a class, try title and name attributes
            if role.kind_of?(Role)
              if role.respond_to?(:title)
                return [role.title.to_s.underscore.downcase.to_sym]
              elsif role.respond_to?(:name)
                return [role.name.to_s.underscore.downcase.to_sym]
              else
                raise RoleInterpolationError
              end
            elsif role.kind_of?(String)
              return [role.underscore.downcase.to_sym]
            elsif role.kind_of(Symbol)
              return [role]
            elsif role.kind_of?(Array)
              return role.map { |r| r.to_s.underscore.downcase.to_sym }
            else
              raise RoleInterpolationError
            end
          # Otherwise, we can't figure it out so raise an Error to make
          # sure the user implements this properly.
          else
            raise RoleInterpolationError
          end
        end
      end
    end
  end
end
