settings = active:true
console.log 'content'

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  console.log 'content msg',request
  if request.type == "reFilter"
    settings.filter = request.filter
    filter()
  sendResponse status: "ok"

#get settings
chrome.runtime.sendMessage type: "getSettings", (set) ->
  console.log "content settings",set
  settings = set     

filter = ->
  filterText = settings.filter
  console.log 'filtering by', filterText
  #clean
  $('[data-txt]').each (i,e) ->
      $(e).text($(e).attr('data-txt')).removeAttr('data-txt').removeClass('filter')
  return if filterText.length == 0
  #filter  
  filterText.split(',').forEach (text) ->    
    htmlElements = [];
    'p,a'.split(',').forEach (htmlElement) ->
      htmlElements.push htmlElement + ":contains('" + text + "')"
      $(htmlElements.join(','))
      .each (i,e) ->
        $(e).attr('data-txt',$(e).text()).text('KABOOM').addClass('filter')


$.expr[":"].contains = jQuery.expr.createPseudo (arg) ->
  (elem) ->
    jQuery(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0

injectAjax = ->
  main = ->
    fireCustomEvent = ->
      document.body.dispatchEvent myEvent
    
    myEvent = document.createEvent("Event")
    myEvent.initEvent "CustomEvent", true, true
    
    #load jQuery
    if $ and $(document).ajaxComplete
      console.log 'not injecting blat!',$(document).ajaxComplete
      $(document).ajaxComplete (event, request, settings) ->
        fireCustomEvent()
        return
    else
      `
_core = window._core || {};
(function(){
    if(_core._preAjaxListeners) return;

    _core._preAjaxListeners = [];
    _core._postAjaxListeners = [];
    _core._fireAjaxEvents = function(flag, href){
        if (!href) return;
        var arr;
        if (flag == 'pre') arr = _core._preAjaxListeners;
        else if (flag == 'post') arr = _core._postAjaxListeners;
        else return;
        for(var i = 0, l = arr.length; i < l; i++){
            var x = arr[i];
            if(typeof x.match == 'string' && href == x.match)
                x.handler();
            else if (x.match.test && x.match.test(href))
                x.handler();
        }
    };

    _core.addPreAjaxListener = function(match, handler){
        _core._preAjaxListeners.push({ match: match, handler: handler });
    };

    _core.addPostAjaxListener = function(match, handler){
        _core._postAjaxListeners.push({ match: match, handler: handler });
    };

    XMLHttpRequest.prototype.open = (function(orig){
        return function(a,b,c){
            this._HREF = b;
            return orig.apply(this, arguments);
        };
    })(XMLHttpRequest.prototype.open);

    XMLHttpRequest.prototype.send = (function(orig){
        return function(){
            _core._fireAjaxEvents('pre', this._HREF);

            var xhr = this,
            waiter = setInterval(function(){
              console.log('trying');
                if(xhr.readyState && xhr.readyState == 4){                  
                    _core._fireAjaxEvents('post', xhr._HREF);
                    fireCustomEvent();
                    clearInterval(waiter);
                }
            }, 150);
            return orig.apply(this, arguments);
        };
    })(XMLHttpRequest.prototype.send);

})();
      `

      return    

  # Lets create the script objects
  injectedScript = document.createElement("script")
  injectedScript.type = "text/javascript"
  injectedScript.text = "(" + main + ")(\"\");"
  (document.body or document.head).appendChild injectedScript
  f = null
  document.body.addEventListener "CustomEvent", ->
    clearTimeout f if f
    f = setTimeout filter, 500
    return

injectAjax()