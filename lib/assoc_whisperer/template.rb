# encoding: utf-8

module AssocWhisperer
  class Template
    attr_reader :opts

    def initialize(action, opts={})
      @action = action[0]=='/' ? action : "#{AssocWhisperer.def_url}/#{action}"
      @opts = opts
      @opts[:value] = AssocWhisperer.def_value unless @opts[:value]
      @opts[:text] = AssocWhisperer.def_text unless @opts[:text]
      @opts[:button] = true if @opts[:button].nil?
    end

    def params(params)
      @params = params
      self
    end

    def value_text(object_or_params, name=nil)
      if object_or_params.is_a?(Hash) && name
        @value = object_or_params[name]
        @text = object_or_params["#{name}_txt"]
      elsif object_or_params
        @value = (object_or_params.send @opts[:value] if object_or_params.respond_to? @opts[:value])
        @text = (object_or_params.send @opts[:text] if object_or_params.respond_to? @opts[:text])
      else
        @value = nil
        @text = nil
      end
      self
    end

    def tag_contents(input_name, field_attrs={})
      input_name = input_name.to_s
      sanitized_id = input_name.dup.delete(']').gsub(/[^-a-zA-Z0-9:.]/, "_")
      text_tag_name = input_name.dup
      text_tag_name.insert (text_tag_name[-1]==']' ? -2 : -1), '_txt'

      contents = value_field_tag sanitized_id, input_name
      contents += text_field_tag "#{sanitized_id}_txt", text_tag_name, field_attrs
      contents + dropdown_button_tag
    end

    def whisperer_settings
      h = {action: @action}
      # h[:cs] = @opts[:client_side] if @opts[:client_side]
      h[:params] = @params if @params
      h
    end

    def value_field_tag(id, name)
      %(<input type="hidden" id="#{id}" name="#{name}" value="#{@value}" class="value_field">)
    end

    def text_field_tag(id, name, attrs={})
      attrs[:size] = 12 unless attrs.has_key? :size
      keys_whitelist = (attrs.keys & [:size, :placeholder, :maxlength, :title])
      attrs = keys_whitelist.inject [] do |arr, k|
        arr << %(#{k}="#{attrs[k]}")
        arr
      end
      %(<input type="text" autocomplete="off" id="#{id}" name="#{name}" value="#{@text}" class="text_field#{' unfilled' unless @value}"#{attrs * ' '}>)
    end

    def dropdown_button_tag
      return '' unless @opts[:button].is_a? TrueClass
      "<span class=\"dropdown_button querying\">\u25BE</span>"
    end

  end
end