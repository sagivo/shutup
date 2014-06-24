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
  filter()    

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

$ ->
  main = ->
    fireCustomEvent = ->
      document.body.dispatchEvent myEvent
    
    myEvent = document.createEvent("Event")
    myEvent.initEvent "CustomEvent", true, true
    
    #load jQuery
    if typeof $ != 'undefined' and typeof $(document).ajaxComplete != 'undefined'
      $(document).ajaxComplete (event, request, settings) ->
        fireCustomEvent()
        return
    else
      `
  (function(){

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