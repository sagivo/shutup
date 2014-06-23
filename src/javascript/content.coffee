settings = active:true
console.log 'content'

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  console.log 'content msg',request
  if request.type == "reFilter"
    settings.filter = request.filter
    filter()
  sendResponse status: "ok"

$ ->  
  chrome.runtime.sendMessage type: "getSettings", (set) ->
    console.log "content settings",set
    settings = set 
    filter() if settings.enabled

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
