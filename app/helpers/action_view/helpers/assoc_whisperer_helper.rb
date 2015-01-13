module ActionView
  module Helpers

    module AssocWhispererHelper

      # This gets called for the most common case of using {FormBuilder#whisperer}, but directly useful for those situations
      # when you have a custom class that has a model as an attribute and you cannot use +form_for+ for this class.
      #
      #   # Borrow helper class:
      #   class Borrow
      #     attr_accessor :book_id, :client
      #     def book
      #       @book ||= Book.find_by(id: book_id)
      #     end
      #   end
      #
      #   # Book model:
      #   class Book < ActiveRecord::Base
      #     validates_presence_of :title
      #   end
      #
      #   # in controller
      #   def request_borrow
      #     @borrow = Borrow.new
      #     @borrow.client = Client.find_by id: params[:client_id]
      #     @borrow.book_id = params[:book_id]
      #     # do what ever you want with the @borrow
      #   end
      #
      #   # the form
      #   <%= form_tag request_borrow_path do %>
      #     <%= hidden_field_tag :client_id, @borrow.client.id %>
      #     book: <%= whisperer :borrow, :book, whisperer_template('get_books', text: :title) %>
      #   <% end %>
      #
      #   #params will look like this: {"borrow" => {"client_id" => 1, "book_id" => 5, "book_title" => "On the road"}}
      #
      # @param [Symbol, String] object_name name of variable that holds the object
      # @param [Symbol, String] method name of method to get desired model
      # @param [AssocWhisperer::Template] template whisperer template that specifies resulting tags.
      # @param [Hash] field_attrs additional attributes for text field input.
      # @return [String] a html content of asscociation whisperer
      def whisperer(object_name, method, template, field_attrs={})
        raise "Helper '#whisperer' cannot be used in Rails < 4.x. Use '#whisperer_tag' instead." if Rails::VERSION::STRING.to_i < 4
        wrapper_whisperer_assets

        Tags::AssocWhispererField.new(object_name, method, self, template, field_attrs).render
      end

      # Form helper for generic associaction whisperer tag. It includes a hidden value field, a text field for user input
      # and optionaly a dropdown button. The list with options that server returns is appended into this tag.
      #
      # This generic version is suitable for most situations. For Rails 3 there's no other option anyway.
      # Arguments sets html name of the value field (the text field has suffix +_txt+ by default),
      # {AssocWhisperer::Template a whisperer template}
      # and additional custom attributes for the text field. Thus the latter example overrides text field
      # name to +book_title+ instead +book_id_txt+ as in the former.
      #
      #   my_book_template = AssocWhisperer::Template.new 'get_books'
      #   whisperer_tag :book_id, my_book_template
      #   whisperer_tag :book_id, my_book_template, name: :book_title, placeholder: "book's title outset"
      #
      # If you want to send additional parametrs with the request please refer to {AssocWhisperer::Template#params}.
      # If you want to preset some value, e.g. in the case you're returning a form back to user, use either
      # {AssocWhisperer::Template#from_params} or {AssocWhisperer::Template#value_text} or {AssocWhisperer::Template#for_object}.
      # The last case depends on what text and value methods are set for given {AssocWhisperer::Template template}.
      #
      #   whisperer_tag :book_id, whisperer_tempate('get_books').from_params(params, 'book_id') # params or any Hash
      #   whisperer_tag :book_id, whisperer_tempate('get_books').value_text(@book.id, @book.to_s)
      #   whisperer_tag :book_id, whisperer_tempate('get_books').for_object(@book)
      #
      # @param [String, Symbol] name base name for the html form inputs.
      # @param [AssocWhisperer::Template] template whisperer template that specifies resulting tags.
      # @param [Hash] field_attrs additional attributes for text field input.
      # @return [String] a html content of asscociation whisperer
      def whisperer_tag(name, template, field_attrs={})
        wrapper_whisperer_assets

        content_tag :span, template.tag_contents(name, field_attrs).html_safe, 'class' => 'assoc_whisperer',
                    'data-opts' => template.whisperer_settings.to_json
      end

      # Wrapper for {AssocWhisperer::Template} constructor
      # @return [AssocWhisperer::Template]
      def whisperer_template(action, opts={})
        AssocWhisperer::Template.new action, opts
      end

      private

      # This is wraper for attaching assets (calls a method specified by {AssocWhisperer.attach_assets} - default
      # is +attach_whisperer_assets+). Gets be called by every whisperer helper but only once assets are attached.
      def wrapper_whisperer_assets
        unless @assoc_whisp_attached
          attach_method = AssocWhisperer.attach_assets
          self.send attach_method if attach_method && self.respond_to?(attach_method)
          @assoc_whisp_attached = true
        end
      end

    end

    class FormBuilder
      # Wraps {AssocWhispererHelper#whisperer} for defaul +FormBuilder+. This enables standard Rails
      # form building syntax for nested models.
      #
      #   # Borrow model:
      #   class Borrow < ActiveRecord::Base
      #     belongs_to :client
      #     belongs_to :book
      #     validates_presence_of :client, :book
      #   end
      #
      #   # Book model:
      #   class Book < ActiveRecord::Base
      #     has_many :borrow
      #     validates_presence_of :title
      #   end
      #
      #   # in controller
      #   @borrow = Borrow.new params.require(:borrow).permit(%i(client_id, book_id))
      #
      #   # A form for request new borrow in library
      #   <%= form_for @borrow do |f| %>
      #     <%= f.hidden_field :client_id %>
      #     book: <%= f.whisperer :book, whisperer_template('get_books', text: :title) %>
      #   <% end %>
      #
      #   #params will look like this: {"borrow" => {"client_id" => 1, "book_id" => 5, "book_title" => "On the road"}}
      #
      # @param [Symbol, String] method name of form object's nested object
      # @param [AssocWhisperer::Template] template whisperer template that specifies resulting tags.
      # @param [Hash] field_attrs additional attributes for text field input.
      # @return [String] a html content of asscociation whisperer
      def whisperer(method, template, field_attrs={})
        @template.whisperer @object_name, method, template, objectify_options(field_attrs)
      end
    end

    autoload :AssocWhispererHelper
    include AssocWhispererHelper
  end
end