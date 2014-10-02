/**
 * Created by doooby on 30.9.14.
 */

document.AssocWhisperer = (function () {
    var proto, klass, all_array = [];

    $(document).ready(function(){
        var w;
        $('.assoc_whisperer').each(function (i, el) {
            w = createWhisperer(el);
            all_array.push(w);
        });
    });

    // This is where Whisperer Object is created - with all hidden inner methods.
    function createWhisperer(dom_node) {
        var el, w, _nodes, _timer;

        el = $(dom_node);
        _nodes = {
            base: el,
            text_field: el.children('.text_field'),
            value_field: el.children('.value_field'),
            list: null
        };

        w = Object.create(proto, {
            nodes: {value: _nodes},
            action: {value: el.attr('data-action')},
            url: {value: el.attr('data-url')},
            focused: {value: false, writable: true},
            filled: {value: _nodes['value_field'].val()!=='', writable: true},
            client_side: {value: el.attr('data-client-side')==='true'},
            full_data: {value: null, writable: true}
        });

        _nodes.text_field.on('keyup', function(e){
            var input_text;
            if (e.keyCode===27) { // escape key
                w.removeList();
                return;
            }
//            if (e.keyCode!==37 && e.keyCode!==39) {} // left & right

            if (_timer) clearTimeout(_timer);
            if (w.filled) {
                w.filled = false;
                _nodes['value_field'].val('');
                _nodes['text_field'].addClass('unfilled');
            }

            input_text = _nodes['text_field'].val();
            if (input_text==='') {
                w.removeList();
            }
            else {
                if (_nodes['list']) {
                    _nodes['list'].addClass('invalid');
                }
                _timer = setTimeout(function () {
                    if (w.client_side) {
                        if (!w.full_data) query(w, null, function (html_text) {
                            w.full_data = $(html_text);
                            showList(digest(input_text));
                        });
                        else showList(digest(input_text));
                    }
                    else query(w, input_text, function (html_text) {
                        showList($(html_text));
                    });
                }, 700);
            }
        });
        _nodes.text_field.on('click', function(){ _nodes['text_field'].select(); });
        _nodes.text_field.focus(function(){ w.focused = true; });
        _nodes.text_field.blur(function(){ onBlur(); });
        el.children('.dropdown_button').on('click', function(){
            var f;
            if (_timer) clearTimeout(_timer);
            if (w.client_side) {
                f = function () {
                    var input_text;
                    if (w.filled) showList(w.full_data);
                    else {
                        input_text = _nodes['text_field'].val();
                        showList(digest(input_text==='' ? null : input_text));
                    }
                    _nodes['list'].focus();
                };
                if (!w.full_data) query(w, null, function (html_text) {
                    w.full_data = $(html_text);
                    f();
                });
                else f();
            }
            else {
                query(w, (w.filled ? null : _nodes['text_field'].val()), function (html_text) {
                    showList($(html_text));
                    _nodes['list'].focus();
                });
            }
        });

        // For local full_data finds matching rows and shows them.
        function digest(input_text) {
            var narrowed_list = w.full_data;
            if (input_text && input_text!=='') {
                input_text = input_text.toLowerCase();
                narrowed_list = $(narrowed_list[0].cloneNode());
                w.full_data.children().each(function () {
                    if (this.innerText.toLowerCase().indexOf(input_text)!==-1)
                        narrowed_list.append($(this).clone());
                });
            }
            return narrowed_list;
        }

        // Attaches a List sent by html string within Whisperer's tag. Positions it underneath the text field.
        function showList (list) {
            var base_dom;
            w.removeList();

            _nodes['list'] = list;

            base_dom = _nodes['base'];
            list.css('min-width', base_dom.width());
            list.css('left', base_dom.offset().left);
            list.css('top', base_dom.position().top + base_dom.outerHeight());
            list.focus(function(){ w.focused = true; });
            list.blur(function(){ onBlur(); });
            base_dom.append(list);

            list.find('div').on('click', function(el){ w.select($(el.currentTarget)); });
        }

        // Hides the List if either of the controls were unfocused.
        function onBlur () {
            w.focused = false;
            setTimeout(function(){ if (!w.focused) w.removeList(); }, 100);
        }

        return w;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          Whisperer prototype                                                   //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    proto = Object.create(Object);

    // Removes the List should there be any.
    Object.defineProperty(proto, 'removeList', {
        value: function () {
            if (this.nodes['list']) {
                this.nodes['list'].detach();
                this.nodes['list'] = null
            }
        }
    });

    // Select given row (must be jQuery object) and hides the List.
    Object.defineProperty(proto, 'select', {
        value: function (row) {
            var text;
            if (row.length!==1) return;
            text = row.text();
            this.nodes['text_field'].val(text);
            this.nodes['text_field'].removeClass('unfilled');
            this.nodes['value_field'].val(row.attr('data-value'));
            this.filled = true;
            this.removeList();
        }
    });

    // Actual ajax request for given input
    function query (w, input, on_success) {
        var btn;
        klass.querying = true;
        btn = w.nodes['base'].find('.dropdown_button');
        btn.addClass('querying');
        $.ajax(w.url, {
                type: 'GET',
                dataType: 'html',
                data: {data_action: w.action, input: (input||'')},
                error: function () { w.removeList(); },
                success: on_success,
                complete: function () {
                    klass.querying = false;
                    btn.removeClass('querying');
                }
            }
        );
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          public interface                                                      //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    klass = Object.create(Object, {querying: {value: false, writable: true}});

    // Return a Whisperer instance by its data-action attribute.
    function findWhisperer(action) {
        var i, w;
        for (i = 0; i < all_array.length; i += 1) {
            w = all_array[i];
            if (w.action===action) return w;
        }
        return null;
    }

    // Sets a value to Whisperer
    Object.defineProperty(klass, 'setValueFor', {
        value: function (value, whisp_action) {
            findWhisperer(whisp_action).nodes['value_field'].val(value);
        }
    });

    // Querries for selected text and seletcs the option if found
    Object.defineProperty(klass, 'selectTextFor', {
        value: function (text, whisp_action) {
            var w;
            w = findWhisperer(whisp_action);
            query(w, text, function (html_text) {
                w.select($(html_text).find('div:contains("'+text+'")'));
            });
        }
    });

    // Querries and seletcs the option by value if found
    // Selects the first option if the given value is '#1'.
    Object.defineProperty(klass, 'selectValueFor', {
        value: function (value, whisp_action) {
            var w;
            w = findWhisperer(whisp_action);
            query(w, null, function (html_text) {
                switch (value) {
                    case '#1':
                        w.select($(html_text).find('div:first'));
                        break;
                    default:
                        w.select($(html_text).find('div[data-value="'+value+'"]'));
                        break;
                }
            });
        }
    });

    return Object.freeze(klass);
})();