# encoding: utf-8
require 'assoc_whisperer/version'
require 'assoc_whisperer/template'

module AssocWhisperer

  class << self
    attr_accessor :def_url, :attach_assets, :def_value, :def_text
  end

  module Rails
    class Engine < ::Rails::Engine
    end
  end

end

AssocWhisperer.def_url = '/whisp'
AssocWhisperer.attach_assets = :attach_whisperer_assets

AssocWhisperer.def_value = :id
AssocWhisperer.def_text = :to_s
