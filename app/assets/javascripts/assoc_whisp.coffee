document.AssocWhispering = {
    # Stores all instantiated Whisperer objects.
    all: []
    # Any active Whisperer#getList method holds this variable in true state.
    working: false
    # Return a Whisperer instance by its data-action attribute.
    find: (action) ->
        for w in document.AssocWhispering.all
            return w if w._action==action
        return null
    # Makes a whisperer (found by its data-action) to select the given text, if present.
    selectTextFor: (text, whisp_action) ->
        w = document.AssocWhispering.find(whisp_action)
        w._last_input = '§'
        w.getList('', false, ->
            w.selectText(text)
        )
    # Makes a whisperer (found by its data-action) to select the given value, if present.
    # Selects the first value if the given value is '#1'.
    selectValueFor: (value, whisp_action) ->
        w = document.AssocWhispering.find(whisp_action)
        w._last_input = '§'
        w.getList('', false, ->
            switch value
                when '#1' then w.select(w._list_tag.find('div:first'))
                else w.selectValue(value)
        )
}

$(document).ready ->
    # attach all whisperers to after document id loaded
    $('.assoc_whisperer').each (i, el) ->
        w = new Whisperer(el)
        document.AssocWhispering.all.push(w)

# This is the class that is instantiated and hold behind a tag with 'assoc_whisperer' css class.
#    It holds an action and url that is supposed to call when user changes the input text field.
#    Request is sent 700ms after last input key hit.
#    On success response attaches the list and shows it.
#    One can click on the drop down button to have the list generated for empty input (ie. '' string).
class Whisperer
    _tag: null
    _text_field: null
    _value_field: null
    _list_tag: null
    _action: null
    _url: null

    _timeout: null
    _last_input: '§'
    _is_filled: false
    _focus: null

    # Constructor takes the element tag, that it shoud hang to (and which holds all the settings).
    constructor: (element) ->
        @_tag = $(element)
        @_action = @_tag.attr('data-action')
        @_url = @_tag.attr('data-url')
        @_text_field = @_tag.children('.text_field')
        @_value_field = @_tag.children('.value_field')

        @_text_field.keyup @text_field_keyup
        @_text_field.click => @_text_field.select()
        @_text_field.focus => @_focus = 'text_field'
        @_text_field.blur @controls_blur
        @_tag.children('.dropdown_button').click @dropdown_button_click

        @_is_filled = @_value_field.val()!=''

########################## E V E N T S ##############################################

    # Catchs ever key pressed to send a request only after the last one (applying 700ms timeout).
    text_field_keyup: (e) =>
        if e.keyCode==40 #down
            return
        else if e.keyCode==27 #escape
            @removeList()
            return
        input = @_text_field.val()
        clearTimeout(@_timeout) if @_timeout
        @setUnfilled() if input!=@_last_input && @_is_filled
        if input==''
            @_last_input = input
            @removeList()
        else
            fnc = => @getList(input)
            @_timeout = setTimeout(fnc, 700)

    # A 'button' to show the whole menu list (like entering an empty input).
    dropdown_button_click: =>
        hold_last = @_last_input
        @_last_input = '§'
        if @_is_filled
            @getList('', true)
            @_last_input = hold_last
        else
            @getList(@_text_field.val(), true)

    # Called by both text_field and list, to ensure that if focused anything else, the list hides itself.
    controls_blur: =>
        @_focus = null
        setTimeout( =>
            @removeList() unless @_focus
        ,100)

########################## L I S T ################################################

    # An Ajax request sent to a server for given url with given action and input as params.
    #     Fires only if input changed. Before the request it visualy deactivates the list, hides it on error.
    #     If success, attaches the list and fires onShow callback, if defined.
    getList: (input, focus=false, onShown=null) =>
        return if input==@_last_input
        @_last_input = input
        @deactivateList()
        document.AssocWhispering.working = true;
        $.ajax(@_tag.attr('data-url'),
            type: 'GET'
            dataType: 'html'
            data: {data_action: @_tag.attr('data-action'), input: input}
            error: @removeList
            success: (data) =>
                @showList(data)
                @_list_tag.focus() if focus
                onShown() if onShown
                document.AssocWhispering.working = false;
        )

    # Attaches a list to html document, within the Whisperer's tag and sets its position to be under the input text field.
    showList: (data) =>
        @removeList()
        @_list_tag = $(data)
        @_list_tag.css('min-width', @_tag.width())
        @_list_tag.css('left', @_tag.offset().left)
        @_list_tag.css('top',  @_tag.position().top + @_tag.outerHeight())

        @_tag.append(@_list_tag)
        @_list_tag.focus => @_focus = 'list'
        @_list_tag.blur @controls_blur

        rows = @_list_tag.find('div')
        rows.click (el) => @select($(el.currentTarget))

    # Adds a class 'inactive' to list to make it visualy distinguishable.
    deactivateList: =>
        return unless @_list_tag
        @_list_tag.addClass('inactive')

    # Detaches list from html, ie. hides it.
    removeList: =>
        return unless @_list_tag
        @_list_tag.detach()
        @_list_tag = null

########################## S E L E C T I O N ############################################

    # Selects given row and sets its value to the hidden value field and removes the list.
    select: (row) =>
        return unless row.length==1
        text = row.text()
        @_text_field.val(text)
        @_value_field.val(row.attr('data-value'))
        @_last_input = text
        @_is_filled = true
        @_text_field.removeClass('unfilled')
        @removeList()

    # Selects row by given value.
    selectValue: (value) =>
        @select(@_list_tag.find('div[data-value='+value+']'))

    # Selects row by given text label.
    selectText: (text) =>
        @select(@_list_tag.find('div:contains("'+text+'")'))

    # Sets Whisperer to 'unfilled' state - no value has been selected (applies css class 'unfilled').
    setUnfilled: =>
        @_is_filled = false
        @_value_field.val('')
        @_text_field.addClass('unfilled')