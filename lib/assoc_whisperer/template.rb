# encoding: utf-8

module AssocWhisperer
  class Template
    attr_reader :action, :opts

    def initialize(action, opts={})
      @action = action
      @opts = opts
    end

    def simple_tag_contents(input_name)
      input_name = input_name.to_s
      sanitized_id = input_name.dup.delete(']').gsub(/[^-a-zA-Z0-9:.]/, "_")
      text_tag_name = input_name.dup
      text_tag_name.insert (text_tag_name[-1]==']' ? -2 : -1), '_txt'

      contents = value_field_tag sanitized_id, input_name, @opts[:value]
      contents += text_field_tag "#{sanitized_id}_txt", text_tag_name, @opts[:text], @opts[:value].blank?
      contents + dropdown_button_tag
    end

    def whisperer_options
      {url: (@opts[:url]||AssocWhisperer.def_url), action: @action, cs: !!@opts[:client_side], pre: !!@opts[:preload]}
    end

    def value_field_tag(id, name, value)
      %(<input type="hidden" id="#{id}" name="#{name}" value="#{value}" class="value_field">)
    end

    def text_field_tag(id, name, value, unfilled=true)
      opts = @opts[:text_field]
      if opts
        opts[:size] ||= 12
        keys_whitelist = (opts.keys & [:size, :placeholder, :maxlength, :title])
        opts = keys_whitelist.inject [] do |arr, k|
          arr << %(#{k}="#{opts[k]}")
          arr
        end
        opts * ' '
      end
      %(<input type="text" id="#{id}" name="#{name}" value="#{value}" class="text_field#{' unfilled' if unfilled}"#{opts}>)
    end

    def dropdown_button_tag
      "<span class=\"dropdown_button\">\u25BE</span>"
    end

  end
end