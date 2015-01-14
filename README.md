# AssocWhisperer

This library served me to bring together some code that was scatered around multiple projects build upon Ruby on Rails. 
Many times I needed a way to let user enter an associated model into form, but users don't know the exact IDs,
they know a title or some part of name, etc. But a server needs exact ID. There comes whisperer, common input field,
using AJAX to show user a narrowed list of desired records.
This is my version build upon Rails form helpers syntax, encapsulating everything needed but beeing smallest possible.

## Installation

Add this line to your application's Gemfile:

    gem 'assoc_whisperer', '~> 2.1.0'
    
## Documentation

Start up yard server and browse the documentation on local:

    bundle exec yard doc && bundle exec yard server 

## Usage

Let's say you have a bussines where to each project can be assigned only on of your many employees. Having a form
of a project you'd have to know IDs of those people id database to fill in. Using this whisperer:

```
<%= form_for @project do |f| %>
  assigned employee: <%= f.whisperer :employee, whisperer_template('get_employees') %>
<% end %>
```

It will render the form with whisperer div that includes a hidden field for desired value and a text field for user input.
(And optionaly a drop down button).

For more generice use (i. e. without form builder), there's another helper:

```
<%= form_tag create_project_path %>
  assigned employee: <%= whisperer_tag :employee_id, whisperer_template('get_employees').from_params(params, :employee_id) %>
<% end %>
```

There's quite a lot to adjust on the background so let's go step by step.  

## Basic case background

There's two things needed to set up - the path for that AJAX querry:

```rb
# set up a controller
class WhispererController < ApplicationController
  def get_employees
    user_input = params[:input]
    return render(nothing: true, status: :bad_request) unless user_input
    @objects = Employee.limit 10
    @objects = @objects.where Employee.arel_table[:surname].matches("%#{user_input}%") unless user_input.empty?
    render 'assoc_whisperer/list', layout: false
  end
end
# add to routes.rb
get 'whisp/:action', to: 'whisperer'
```

And a way to include assets (js and css) on the page

```
# add to application.js
//= require assoc_whisp
# add to application.css
*= require assoc_whisp_example
```

Again, the most simple whisperer tag:

```
<%= form_for @project do |f| %>
  assigned employee: <%= f.whisperer :employee, whisperer_template('get_employees') %>  
<% end %>
```

User fills in 'mori', waits for options to pop up, selects from list the desired person and submits the form:

```rb
# you'll receive these params
{'employee_id' => '5', 'employee_txt' => 'Dean Moriarty'}
# given this record exists:
Employee.find(5).to_s
# => "Dean Moriarty"
```

### Changing default settings

In the basic case, we were stuck with default options. First there's that you get ID behind #id of the object 
and user sees string that returns #to_s method. 

```rb
AssocWhisperer.def_value = :my_id           # def: :id
AssocWhisperer.def_text = :to_my_string     # def: :to_s
```

You can modify the path for AJAX request. reflect the change also in routes.rb  

```rb
AssocWhisperer.def_url = '/whisperer/path'  # def: '/whisp'
```

If you don't want to attach whisperers assets for every page (i.e. in application.js), there's option to define a method
that whisperer helpers call internally so it'll be attached only whether whisperer is present on the page.

```rb
# in application_helper.rb
def attach_whisperer_assets
  content_for :addon_assets, javascript_include_tag('assoc_whisp')
  content_for :addon_assets, stylesheet_link_tag('assoc_whisp_example')
end
# to change the helper method
AssocWhisperer.attach_assets = :custom_whisperer_attach_method 
```

To make this work, you need insert that content into your layout file, within <head> preferably:

```
<%= content_for :addon_assets %>
```

### Templates

If you wanth to whisper the same fing on multiple forms, you can save somewhere the template. The template is there 
even for change things around.

```rb
whisperer_template('action') # is just wrapper for AssocWhisperer::Template constructor
# you can change methods of text and value
f.whisperer :employee ,whisperer_template('get_employees', text: :full_name, value: :personal_key)
# you can show up the drop down button
f.whisperer :employee ,whisperer_template('get_employees', button: true)
# or define exact path
f.whisperer :employee ,whisperer_template('/whisperer/get_employees')
```

### Another way to set up path for AJAX:
 
There a way to send custom params with that particular whisperer. That's usefull if you want to completly
change controller side of AJAX calls.
 
```rb
f.whisperer :employee ,whisperer_template('/whisperer').params('get' => 'employees')
# routes.rb
get 'whisperer', to: 'whisperer#whisper'
```

## More complex examples

For sequent examples we're going to use this controller set up:

```rb
class WhispererController < ApplicationController
  layout false
  before_filter :get_input
  
  def get_employees
    @objects = Employee.limit 10
    @objects = @objects.where deparatment: params[:department] if params[:department].present?     
    @objects = @objects.where Employee.arel_table[:surname].matches("%#{user_input}%") unless user_input.empty?
    render 'assoc_whisperer/list', locales: {text: :full_name} # THIS IS IMPORTANT to show right text in list
  end
  
  private
  
  def get_input
    @input = params[:input]
    render nothing: true, status: :bad_request unless @input
  end
  
end
```

### Using the most convenient rails form building syntax

If it's the case that can use form builder for given object, it's easy to make things work. This way values will be filled
even if you return the form to user because some validation errors, for example. Since params will include following,
you can simply create object of Project and input field will fill automaticaly with what employee user selected:

```rb
# params include:
{"project" => {"employee_id" => 5, "employee_txt" => "Dean Moriarty"}}

# in controller's particular action
@project = Project.new params.require(:project).permit(:employee_id)
```

And whisperer tag only needs this:

```
<%= form_for @project do |f| %>
  assigned employee: <%= f.whisperer :employee, whisperer_template('get_employees', text: :full_name).
                         params(department: 'management') %>  
<% end %>
```

### Use without form builder

Since whisperer tag is not bound to a project that holds association to selected employee, you have to fill in values 
of that employee back manually. If you have the employee object or it's nil:

```rb
whisperer_tag :employee_id, whisperer_template('get_employees', text: :full_name).
  params(department: 'management').for_object(@selected_employee)  
```

Or set particular values:

```rb
whisperer_tag :employee_id, whisperer_template('get_employees', text: :full_name).
  params(department: 'management').value_text(params[:employee_id], params[:employee_id_text])  
```

There's this short cut for when those values are in some hash, that paramas exactly is:

```rb
whisperer_tag :employee_id, whisperer_template('get_employees', text: :full_name).
  params(department: 'management').from_params(params, :employee_id)  
``` 




## Contributing

1. Fork it ( https://github.com/[my-github-username]/assoc_whisperer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
