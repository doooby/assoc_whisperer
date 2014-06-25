# encoding: utf-8
require "assoc_whisperer/version"

module AssocWhisperer

  class << self
    attr_accessor :def_url, :attach_assets_method
  end

  module Rails
    class Engine < ::Rails::Engine
    end
  end

end

AssocWhisperer.def_url = '/whisp'
AssocWhisperer.attach_assets_method = :attach_assoc_whisperer_assets
