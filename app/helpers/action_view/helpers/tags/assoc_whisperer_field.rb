module ActionView
  module Helpers
    module Tags
      class AssocWhispererField < Base

        def initialize(object_name, method_name, template_object, action, options={})
          options[:value_method] = :id unless options.has_key? :value_method
          options[:text_method] = :to_s unless options.has_key? :text_method
          super object_name, method_name, template_object, options
          @template = AssocWhisperer::Template.new action, @options
        end

        def render
          contents = @template.value_field_tag value_tag_id, value_tag_name, value_tag_value
          contents += @template.text_field_tag text_tag_id, text_tag_name, text_tag_value, !whispered_object
          contents += @template.dropdown_button_tag

          content_tag :span, contents.html_safe, 'class' => 'assoc_whisperer',
                      'data-opts' => @template.whisperer_options.to_json
        end

        private

        def whispered_object
          @whispered_object ||= value @object
        end

        def whispered_object_attribute(method)
          wo = whispered_object
          wo.send method if wo && wo.respond_to?(method)
        end

        def text_tag_name
          "#{@object_name}[#{text_sanitized_method_name}]"
        end

        def text_tag_id
          "#{sanitized_object_name}_#{text_sanitized_method_name}"
        end

        def text_tag_value
          text = @template.opts[:text_method]
          text = if text.respond_to? :call
                   text.call whispered_object
                 else
                   whispered_object_attribute(text)
                 end
          ERB::Util.html_escape text
        end

        def text_sanitized_method_name
          @text_sanitized_method_name ||= "#{@template.opts[:name] || @method_name}_txt".sub(/\?$/,"")
        end

        def value_tag_name
          "#{@object_name}[#{value_sanitized_method_name}]"
        end

        def value_tag_id
          "#{sanitized_object_name}_#{value_sanitized_method_name}"
        end

        def value_tag_value
          whispered_object_attribute @template.opts[:value_method]
        end

        def value_sanitized_method_name
          return @value_sanitized_method_name if defined? @value_sanitized_method_name
          wsmn = if @template.opts[:name]
                   @template.opts[:name].to_s
                 else
                   "#{@method_name}_#{@template.opts[:value_method]}"
                 end
          @value_sanitized_method_name = wsmn.sub(/\?$/,"")
        end

      end
    end
  end
end