module ActionView
  module Helpers

    module AssocWhispererHelper

      # Createa an association whisperer tag, that will attach javascript object to self
      # allowing user to select a text but stores something differend (mostly respective id).
      #
      # ==== Examples
      #   assoc_whisperer :task, :worker, :workers, size: 25, url: '/whisp'
      #   # => <span class="assoc_whisperer" data-action="workers" data-url="/whisp">
      #        <input class="value_field" id="task_worker_id" name="task[worker_id]" type="hidden" value="">
      #        <input autocomplete="off" class="text_field unfilled" id="task_worker_txt" name="task[worker_txt]" size="25" type="text" value="">
      #        <span class="dropdown_button">▾</span></span>
      #
      # Let's say your association looks like this:
      #
      #   class Task
      #     belongs_to :worker, class_name: 'Worker', foreign_key: :manager
      #   end
      #   class Worker
      #     def full_name; end
      #     def manager_id; end
      #   end
      #
      #   assoc_whisperer :task, :worker, :workers, name: :manager, value_method: :manager_id, text_method: :full_name
      #   # => <span class="assoc_whisperer" data-action="workers" data-url="">
      #        <input class="value_field" id="task_manager" name="task[manager]" type="hidden" value="">
      #        <input autocomplete="off" class="text_field unfilled" id="task_manager_txt" name="task[manager_txt]" size="12" type="text" value="">
      #        <span class="dropdown_button">▾</span></span>
      #
      # And the 'value_field' would be filled by +manager_id+ of +worker+ associated to +task+, 'text_field' by his +full_name+
      #
      def assoc_whisperer(object_name, method, data_action, options={})
        wrapper_assoc_whisperer_assets

        options[:url] = AssocWhisperer.def_url unless options.has_key? :url
        Tags::AssocWhispererField.new(object_name, method, self, data_action, options).render
      end

      def assoc_whisperer_tag(name, data_action, options = {})
        wrapper_assoc_whisperer_assets

        sanitized_id = name.to_s.delete(']').gsub(/[^-a-zA-Z0-9:.]/, "_")
        text_tag_name = name.to_s.dup
        text_tag_name.insert (text_tag_name[-1]==']' ? -2 : -1), '_txt'

        content = %Q(<input class="value_field" id="#{sanitized_id}" name="#{name}" type="hidden")
        content << %Q( value="#{options[:value]}">)
        content << %Q(<input autocomplete="off" class="text_field#{' unfilled' if options[:value].blank?}")
        content << %Q( id="#{sanitized_id}_txt" name="#{text_tag_name}" size="#{options[:size]||12}")
        content << %Q( type="text" value="#{options[:text]}">)
        content << %Q(<span class="dropdown_button">\u25BE</span>)
        content_tag :span, content.html_safe, 'data-url' => (options[:url]||AssocWhisperer.def_url),
                    'data-action' => data_action, 'class' => 'assoc_whisperer'
      end

      private

      def wrapper_assoc_whisperer_assets
        unless @assoc_whisp_attached
          attach_method = AssocWhisperer.attach_assets_method
          self.send attach_method if attach_method && self.respond_to?(attach_method)
          @assoc_whisp_attached = true
        end
      end

    end

    class FormBuilder
      def assoc_whisperer(method, data_action, options = {})
        @template.assoc_whisperer @object_name, method, data_action, objectify_options(options)
      end
    end

    autoload :AssocWhispererHelper
    include AssocWhispererHelper
  end
end