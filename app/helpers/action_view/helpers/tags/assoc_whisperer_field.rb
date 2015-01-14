module ActionView
  module Helpers
    module Tags # :nodoc:
      class AssocWhispererField < Base # :nodoc:

        def initialize(object_name, method_name, template_object, whisp_template, options={})
          @whisp_template = whisp_template
          super object_name, method_name, template_object, options
        end

        def render
          @whisp_template.for_object whispered_object

          contents = @whisp_template.value_field_tag value_tag_id, value_tag_name
          contents += @whisp_template.text_field_tag text_tag_id, text_tag_name, @options
          contents += @whisp_template.dropdown_button_tag

          content_tag :span, contents.html_safe, 'class' => 'assoc_whisperer',
                      'data-opts' => @whisp_template.whisperer_settings.to_json
        end

        private

        def whispered_object
          @whispered_object ||= value @object
        end

        def text_tag_name
          "#{@object_name}[#{text_sanitized_method_name}]"
        end

        def text_tag_id
          "#{sanitized_object_name}_#{text_sanitized_method_name}"
        end

        def text_sanitized_method_name
          @text_sanitized_method_name ||= "#{@whisp_template.opts[:name] || @method_name}_txt".sub(/\?$/,"")
        end

        def value_tag_name
          "#{@object_name}[#{value_sanitized_method_name}]"
        end

        def value_tag_id
          "#{sanitized_object_name}_#{value_sanitized_method_name}"
        end

        def value_sanitized_method_name
          return @value_sanitized_method_name if defined? @value_sanitized_method_name
          name = if @whisp_template.opts[:name]
                   @whisp_template.opts[:name].to_s
                 else
                   "#{@method_name}_#{@whisp_template.opts[:value]}"
                 end
          @value_sanitized_method_name = name.sub(/\?$/, '')
        end

      end
    end
  end
end