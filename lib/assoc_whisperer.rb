# encoding: utf-8
require 'assoc_whisperer/version'
require 'assoc_whisperer/template'

module AssocWhisperer

  class << self
    attr_accessor :def_url, :attach_assets_method, :def_value_method, :def_text_method
  end

  module Rails
    class Engine < ::Rails::Engine
    end
  end

  def self.value_field_html(id, name, value)
    %(<input type="hidden" id="#{id}" name="#{name}" value="#{value}" class="value_field">)
  end

  def self.text_field_html(id, name, value, unfilled=true, opts={})
    opts = opts.keys.inject([]){|arr, k| arr << %(#{k}="#{opts[k]}"); arr }*' '
    %(<input type="text" id="#{id}" name="#{name}" value="#{value} class="text_field#{' unfilled' if unfilled}"#{opts}>)
  end

  def self.dropdown_button_html
    @dropdown_button_html ||= "<span class=\"dropdown_button\">\u25BE</span>"
  end

end

AssocWhisperer.def_url = '/whisp'
AssocWhisperer.attach_assets_method = :attach_assoc_whisperer_assets

AssocWhisperer.def_value_method = :id
AssocWhisperer.def_text_method = :to_s
