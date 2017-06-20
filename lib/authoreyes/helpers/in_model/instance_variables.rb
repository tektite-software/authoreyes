module Authoreyes
  module Helpers
    module InModel
      module InstanceVariables
        # +include_privileges_for+
        # Returns the same object with an additional attribute containing the
        # results of user.priveleges_on.  Useful for simple Rails APIs when
        # you want to render JSON but also include authorization data
        # the frontend.
        # Call on an ActiveRecord object instance, pass in an optional User.
        #
        # ==== Example
        #
        #   test_model.include_privileges_for(current_user).attributes
        #   => {"id"=>3, "title"=>"Test Model 3", "body"=>"Testing 1 2 3.", "created_at"=>Sat, 23 Jul 2016 23:39:42 UTC +00:00, "updated_at"=>Sat, 23 Jul 2016 23:39:42 UTC +00:00, "user_id"=>2, "privileges_for_user"=>{:manage=>true, :create=>true, :read=>true, :update=>true, :delete=>true, :index=>true, :show=>true, :new=>true, :edit=>true, :destroy=>true}}
        def include_privileges_for(user=nil)
          # Get user privileges or if user if nil, guest privileges.
          privileges = if user.nil?
            Authoreyes::Helpers.guest_privileges_on(self)
          else
            user.privileges_on(self)
          end

          # Add :privileges_for_user as an attribute.
          self.class_eval do
            attr_accessor :privileges_for_user
          end

          # Define :privileges_for_user as privileges obtained earlier.
          self.privileges_for_user = privileges

          # Even though we have already set and defined an `attr_accessor` for
          # the object, Rails will not include it as a Model attribute and
          # will therefore not include it when calling `object.to_hash` or
          # `object.to_json`, for example.  We therefore override the =
          # attributes method to include the previously set attribute.
          self.instance_eval do
            def attributes
              super.merge({"privileges_for_user" => @privileges_for_user})
            end
          end

          # Finally, we return the original object to make method chaining easy.
          self
        end
      end
    end
  end
end
