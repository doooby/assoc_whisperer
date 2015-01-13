# encoding: utf-8

module AssocWhisperer

  # This object specifies what will a whisperer tag look like. {ActionView::Helpers::AssocWhispererHelper#whisperer_template}
  # is a markup for this class.
  class Template
    attr_reader :opts

    # Creates a template for whisperer.
    # @param [String] action can be just a tail of url ({AssocWhisperer.def_url}
    #   will be prefix) or full path eg.: +'/whisperer/specific_path'+.
    # Options may include:
    # +:value+:: a method name that is called on given object to get the value the hidden field will be filled with.
    #            If not specified then {AssocWhisperer.def_value} is used.
    # +:text+:: a method name that is called on given object to get the value for the text field.
    #           If not specified then {AssocWhisperer.def_text} is used.
    # +:button+:: specifies whether dropdown button will be present. Defaults to true.
    def initialize(action, opts={})
      @action = action[0]=='/' ? action : "#{AssocWhisperer.def_url}/#{action}"
      @opts = opts
      @opts[:value] = AssocWhisperer.def_value unless @opts[:value]
      @opts[:text] = AssocWhisperer.def_text unless @opts[:text]
      @opts[:button] = true if @opts[:button].nil?
    end

    # Sets parameters that will be included to html request. Usefull to specify additional options. Because this returns
    # the template object itself, it is easy to use in views.
    #   whisperer_tag :foo, whisperer_template('action').params(bar: 5)
    # Whisperer will call something like this url +/whisp/action?bar=5+
    # @param [Hash] params
    # @return [Template]
    def params(params)
      @params = params
      self
    end

    # Sets value and text for given object and returns tepmlate object itself for ease of use.
    #   whisperer_tag :foo, whisperer_template('action', text: :to_readable_text).value_text(@foo_object)
    #   # value => FooObject#id (since :id is default method for value specified in AssocWhisperer.def_value)
    #   # text => FooObject#to_readable_text
    # @param [Object] object from which will be the value and text taken.
    # @return [Template]
    def for_object(object)
      @value = (object.send @opts[:value] if object.respond_to? @opts[:value])
      @text = (object.send @opts[:text] if object.respond_to? @opts[:text])
      self
    end

    # Sets value and text that is specified in given hash (like params) and returns tepmlate object itself.
    # In case text is under something else then value name with suffix +_txt+, specify it in last argument.
    #   params = {'foo' => '15', 'foo_txt' => 'Foo number 15'}
    #   whisperer_tag :foo, whisperer_template('action').from_params(params, 'foo')
    #   params = {'foo' => '15', 'foo_bar' => 'Foo number 15'}
    #   whisperer_tag :foo, whisperer_template('action').from_params(params, 'foo', 'foo_bar')
    # @param [Hash] hash containing values (like params)
    # @param [String] value_name the key under which is the value in the hash
    # @param [String] text_name the key under which is the text in the hash
    # @return [Template]
    def from_params(hash, value_name, text_name=nil)
      @value = hash[value_name]
      @text = hash[text_name || "#{value_name}_txt"]
      self
    end

    # Sets value and text and returns tepmlate object itself.
    #   whisperer_tag :foo, whisperer_template('action').value_text(foo.id, foo.to_s)
    # @param [Object] value that will converted to string and filled into hidden input field
    # @param [String] text that will be filled into text field
    # @return [Template]
    def value_text(value, text)
      @value = value
      @text = text
      self
    end

    # Creates html contents for whisperer (used by {ActionView::Helpers::AssocWhispererHelper#whisperer_tag})
    # @param [String] input_name for html form name of value and text field tags
    # @param [Hash] field_attrs additional attributes for text field tag
    # @return [String] tag html content
    def tag_contents(input_name, field_attrs={})
      input_name = input_name.to_s
      sanitized_id = input_name.dup.delete(']').gsub(/[^-a-zA-Z0-9:.]/, "_")
      text_tag_name = input_name.dup
      text_tag_name.insert (text_tag_name[-1]==']' ? -2 : -1), '_txt'

      contents = value_field_tag sanitized_id, input_name
      contents += text_field_tag "#{sanitized_id}_txt", text_tag_name, field_attrs
      contents + dropdown_button_tag
    end

    # This is used for whisperer's +data-opts+ html attribute
    # @return [Hash] whisperer's settings
    def whisperer_settings
      h = {action: @action}
      # h[:cs] = @opts[:client_side] if @opts[:client_side]
      h[:params] = @params if @params
      h
    end

    # Creates html contents for hidden field that holds a value
    # @return [String] hidden field html
    def value_field_tag(id, name)
      %(<input type="hidden" id="#{id}" name="#{name}" value="#{@value}" class="value_field">)
    end

    # Creates html contents for text field
    # @return [String] text field html
    def text_field_tag(id, name, attrs={})
      attrs[:size] = 12 unless attrs.has_key? :size
      keys_whitelist = (attrs.keys & [:size, :placeholder, :maxlength, :title])
      attrs = keys_whitelist.inject [] do |arr, k|
        arr << %(#{k}="#{attrs[k]}")
        arr
      end
      %(<input type="text" autocomplete="off" id="#{id}" name="#{name}" value="#{@text}" class="text_field#{' unfilled' unless @value}"#{attrs * ' '}>)
    end

    # Creates html contents for drop down button. If +:button+ option is anything else then TrueClass,
    # empty string is returned.
    # @return [String] span html
    def dropdown_button_tag
      return '' unless @opts[:button].is_a? TrueClass
      "<span class=\"dropdown_button querying\">\u25BE</span>"
    end

  end
end