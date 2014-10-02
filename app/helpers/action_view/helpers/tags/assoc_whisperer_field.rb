module ActionView
  module Helpers
    module Tags # :nodoc:
      class AssocWhispererField < Base # :nodoc:

        def initialize(object_name, method_name, template_object, action, options={})
          @action = action
          options[:value_method] = :id unless options.has_key? :value_method
          options[:text_method] = :to_s unless options.has_key? :text_method
          super object_name, method_name, template_object, options
        end

        def render
          content = %Q(<input class="value_field" id="#{value_tag_id}" name="#{value_tag_name}" type="hidden")
          content << %Q( value="#{value_tag_value}">)
          content << %Q(<input autocomplete="off" class="text_field#{' unfilled' unless whispered_object}")
          content << %Q( id="#{text_tag_id}" name="#{text_tag_name}" size="#{@options[:size]||12}")
          content << %Q( type="text" value="#{text_tag_value}">)
          content << %Q(<span class="dropdown_button">\u25BE</span>)
          content_tag :span, content.html_safe, 'data-url' => @options[:url], 'data-action' => @action,
                      'data-client-side' => (@options[:client_side] && 'true'), 'class' => 'assoc_whisperer'
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
          text = @options[:text_method]
          text = if text.respond_to? :call
                   text.call whispered_object
                 else
                   whispered_object_attribute(text)
                 end
          ERB::Util.html_escape text
        end

        def text_sanitized_method_name
          return @text_sanitized_method_name if defined? @text_sanitized_method_name
          wsmn = if @options[:name]
                   "#{@options[:name]}_txt"
                 else
                   "#{@method_name}_txt"
                 end
          @text_sanitized_method_name = wsmn.sub(/\?$/,"")
        end

        def value_tag_name
          "#{@object_name}[#{value_sanitized_method_name}]"
        end

        def value_tag_id
          "#{sanitized_object_name}_#{value_sanitized_method_name}"
        end

        def value_tag_value
          whispered_object_attribute @options[:value_method]
        end

        def value_sanitized_method_name
          return @value_sanitized_method_name if defined? @value_sanitized_method_name
          wsmn = if @options[:name]
                   @options[:name].to_s
                 else
                   "#{@method_name}_#{@options[:value_method]}"
                 end
          @value_sanitized_method_name = wsmn.sub(/\?$/,"")
        end

      end
    end
  end
end