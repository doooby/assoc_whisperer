# encoding: utf-8

module AssocWhisperer
  class Template

    def initialize(action, opts={})
      @action = action[0]=='/' ? action : "#{AssocWhisperer.def_url}/#{action}"
      @value = opts[:value]
      @text = opts[:text]
      @client_side = opts[:client_side]
    end

    def params(params)
      @params = params
      self
    end

    def value_text(object_or_params, value=nil, text=nil)
      if object_or_params.is_a? Hash
        raise 'Value argument cannot be nil.' unless value
        text = "#{value}_txt" unless text
        @value = object_or_params[value]
        @text = object_or_params[text]
      elsif object_or_params
        value ||= AssocWhisperer.def_value
        text ||= AssocWhisperer.def_text
        @value = (object_or_params.send value if object_or_params.respond_to? value)
        @text = (object_or_params.send text if object_or_params.respond_to? text)
      end
      self
    end

    def tag_contents(input_name, field_attrs={})
      input_name = input_name.to_s
      sanitized_id = input_name.dup.delete(']').gsub(/[^-a-zA-Z0-9:.]/, "_")
      text_tag_name = input_name.dup
      text_tag_name.insert (text_tag_name[-1]==']' ? -2 : -1), '_txt'

      contents = value_field_tag sanitized_id, input_name, @value
      contents += text_field_tag "#{sanitized_id}_txt", text_tag_name, @text, @value.blank?, field_attrs
      contents + dropdown_button_tag
    end

    def whisperer_settings
      h = {action: @action}
      h[:cs] = @client_side if @client_side
      h[:params] = @params if @params
      h
    end

    def value_field_tag(id, name, value)
      %(<input type="hidden" id="#{id}" name="#{name}" value="#{value}" class="value_field">)
    end

    def text_field_tag(id, name, value, unfilled=true, attrs={})
      attrs[:size] = 12 unless attrs.has_key? :size
      keys_whitelist = (attrs.keys & [:size, :placeholder, :maxlength, :title])
      attrs = keys_whitelist.inject [] do |arr, k|
        arr << %(#{k}="#{attrs[k]}")
        arr
      end
      %(<input type="text" autocomplete="off" id="#{id}" name="#{name}" value="#{value}" class="text_field#{' unfilled' if unfilled}"#{attrs * ' '}>)
    end

    def dropdown_button_tag
      "<span class=\"dropdown_button querying\">\u25BE</span>"
    end

  end
end