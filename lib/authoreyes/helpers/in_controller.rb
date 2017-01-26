module Authoreyes
  module Helpers
    # This module handles authorization at the Controller level.  It allows
    # various actions within the controller to be configured to work with
    # Authoreyes, only permitting access to that action if certain
    # conditions are met, according to the defined Authorization Rules.
    module InController
      extend ActiveSupport::Concern
      # ActiveSupport.on_load :action_controller do
      #   extend
      # end

      # ApplicationController.send :before_action, :redirect_if_unauthorized

      # TODO: Implement this!
      def filter_resource_access(options = {})

      end

      ActionController::Base.send(:define_method, :redirect_if_unauthorized) do
        begin
          permitted_to! action_name
        rescue Authoreyes::Authorization::NotAuthorized => e
          session[:request_unauthorized] = true
          puts e
          redirect_back fallback_location: root_path,
                        status: :found,
                        alert: 'You are not allowed to do that.'
        end
      end

      ActionController::Base.send(:define_method, :set_unauthorized_status_code) do
        if session[:request_unauthorized] == true
          session.delete :request_unauthorized
          response.status = :forbidden
        end
      end

      ActionController::Metal.send(:define_method, :authorization_object) do
        if params[:id].present?
          begin
            controller_name.singularize.capitalize.constantize.find(params[:id])
          rescue NameError
            logger.warn "[Authoreyes] Could not interpolate object!"
          end
        else
          nil
        end
      end

      ActionController::API.send(:define_method, :render_unauthorized) do
        begin
          permitted_to! action_name, authorization_object
        rescue Authoreyes::Authorization::NotAuthorized => e
          logger.warn "[Authoreyes] #{e}"
          response_object = ActiveModelSerializers::Model.new()
          response_object.attributes.merge!({
            action: action_name,
            controller: controller_name
          })
          response_object.errors.add :action, e
          # Assumes ActiveModel::Serializers is used.
          # If not used, you will have to override `render_unauthorized`
          # in your ApplicationController.
          render json: response_object, status: :forbidden, adapter: :json_api, serializer: ActiveModel::Serializer::ErrorSerializer
        end
      end

      # If the current user meets the given privilege, permitted_to? returns true
      # and yields to the optional block.  The attribute checks that are defined
      # in the authorization rules are only evaluated if an object is given
      # for context.
      #
      # See examples for Authorization::AuthorizationHelper #permitted_to?
      #
      # If no object or context is specified, the controller_name is used as
      # context.
      # TODO: Use permit? instead of permit!
      # +privelege+ is the symbol name of the privele checked
      # +object_or_symbol+ is the object the privelege is checked on
      def permitted_to?(privelege, object_or_symbol = nil, options = {})
        if Authoreyes::ENGINE.permit!(
          privelege, options_for_permit(object_or_symbol, options, false)
        )
          yield if block_given?
          true
        else
          false
        end
      end

      # Works similar to the permitted_to? method, but
      # throws the authorization exceptions, just like Engine#permit!
      # +privelege+ is the symbol name of the privele checked
      # +object_or_symbol+ is the object the privelege is checked on
      def permitted_to!(privelege, object_or_symbol = nil, options = {})
        Authoreyes::ENGINE.permit!(
          privelege, options_for_permit(object_or_symbol, options, true)
        )
      end

      private

      # Create hash of options to be used with ENGINE's permit methods
      def options_for_permit(object_or_sym = nil, options = {}, bang = true)
        context = object = nil
        if object_or_sym.nil?
          context = controller_name.to_sym
        elsif !Authorization.is_a_association_proxy?(object_or_sym) and object_or_sym.is_a?(Symbol)
          context = object_or_sym
        else
          object = object_or_sym
        end

        result = {:object => object,
          :context => context,
          # :skip_attribute_test => object.nil?,
          :bang => bang}.merge(options)
        result[:user] = current_user unless result.key?(:user)
        result
      end

      class_methods do

      end
    end
  end
end
