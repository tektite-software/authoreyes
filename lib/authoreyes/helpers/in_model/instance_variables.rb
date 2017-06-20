module Authoreyes
  module Helpers
    module InModel
      module InstanceVariables
        def include_privileges_for(user=nil)
          privileges = if user.nil?
            Authoreyes::Helpers.guest_privileges_on(self)
          else
            user.privileges_on(self)
          end

          self.class_eval do
            attr_accessor :privileges_for_user
          end

          self.privileges_for_user = privileges

          self.instance_eval do
            def attributes
              super.merge({"privileges_for_user" => @privileges_for_user})
            end
          end

          self
        end
      end
    end
  end
end
