settings = enabled:false; filterFlag = true
console.log 'content'

#subscribe to events
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  console.log 'content msg',request  
  if request.type == "reFilter"
    settings = request
    filter()
  sendResponse status: "ok"

#get initial settings
chrome.runtime.sendMessage type: "getSettings", (set) ->
  settings = set 
  filter()  

filter = ->
  return unless settings?.enabled
  if filterFlag #filter no faster than each 500 ms
    filterFlag = false; 
    setTimeout (->
      filterFlag = true
    ), 500
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
          $(e).attr('data-txt',$(e).text()).text('SHUTUP!').addClass('filter')

$ ->
  $.expr[":"].contains = jQuery.expr.createPseudo (arg) ->
    (elem) ->
      jQuery(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0

  main = ->
    fireCustomEvent = ->
      document.body.dispatchEvent myEvent
    
    myEvent = document.createEvent("Event")
    myEvent.initEvent "CustomEvent", true, true
    
    #hook to ajax events
    if typeof $ != 'undefined' and typeof $(document).ajaxComplete != 'undefined'
      $(document).ajaxComplete (event, request, settings) ->
        fireCustomEvent()
        return
    else #an ugly hook to mimik jQuery ajaxComplete in case page doesn't have jQuery
      `(function(){
        XMLHttpRequest.prototype.send = (function(orig){
            return function(){
                var xhr = this,
                waiter = setInterval(function(){
                  console.log('trying2');
                    if(xhr.readyState && xhr.readyState == 4){                  
                        fireCustomEvent();
                        clearInterval(waiter);
                    }
                }, 250);
                return orig.apply(this, arguments);
            };
        })(XMLHttpRequest.prototype.send);
      })();`
      return    

  # Lets create the script objects to inject
  injectedScript = document.createElement("script")
  injectedScript.type = "text/javascript"
  injectedScript.text = "(" + main + ")(\"\");"
  (document.body or document.head).appendChild injectedScript
  f = null
  document.body.addEventListener "CustomEvent", ->
    filter()
    return 