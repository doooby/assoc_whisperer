module ActionView
  module Helpers

    module AssocWhispererHelper

      # def whisperer(object_name, method, data_action, options={})
      #   raise "Helper '#assoc_whisperer' is for Rails >= 4.x. Use '#assoc_whisperer_tag' instead." if Rails::VERSION::STRING.to_i < 4
      #   wrapper_whisperer_assets
      #
      #   Tags::AssocWhispererField.new(object_name, method, self, data_action, options).render
      # end

      def whisperer_tag(name, template, field_attrs={})
        wrapper_whisperer_assets

        content_tag :span, template.tag_contents(name, field_attrs).html_safe, 'class' => 'assoc_whisperer',
                    'data-opts' => template.whisperer_settings.to_json
      end

      def whisperer_template(action, opts={})
        AssocWhisperer::Template.new action, opts
      end

      private

      def wrapper_whisperer_assets
        unless @assoc_whisp_attached
          attach_method = AssocWhisperer.attach_assets
          self.send attach_method if attach_method && self.respond_to?(attach_method)
          @assoc_whisp_attached = true
        end
      end

    end

    class FormBuilder
      # def whisperer(method, data_action, options = {})
      #   @template.assoc_whisperer @object_name, method, data_action, objectify_options(options)
      # end
    end

    autoload :AssocWhispererHelper
    include AssocWhispererHelper
  end
end