module ActionView
  module Helpers

    module AssocWhispererHelper

      def whisperer(object_name, method, template, field_attrs={})
        raise "Helper '#whisperer' cannot be used in Rails < 4.x. Use '#whisperer_tag' instead." if Rails::VERSION::STRING.to_i < 4
        wrapper_whisperer_assets

        Tags::AssocWhispererField.new(object_name, method, self, template, field_attrs).render
      end

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
      def whisperer(method, template, field_attrs={})
        @template.whisperer @object_name, method, template, objectify_options(field_attrs)
      end
    end

    autoload :AssocWhispererHelper
    include AssocWhispererHelper
  end
end