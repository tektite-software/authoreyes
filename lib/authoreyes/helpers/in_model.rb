require 'authoreyes/helpers/in_model/instance_variables'

module Authoreyes
  module Helpers
    module InModel
      extend ActiveSupport::Concern
      include InstanceVariables

      module ClassMethods
        def include_privileges_for(user=nil)
          all.map do |item|
            item.include_privileges_for(user)
          end
        end
      end
    end
  end
end
