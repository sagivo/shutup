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
  text = settings.filter
  console.log 'filtering by', text
  $('[data-txt]').each (i,e) ->
    $(e).text($(e).attr('data-txt')).removeAttr('data-txt')
  $("a:contains('" + text + "'),p:contains('" + text + "'),span:contains('" + text + "'),td:contains('" + text + "'),th:contains('" + text + "')")
  .each (i,e) ->
    $(e).attr('data-txt',$(e).text()).text('KABOOM').css({'background-color':'red', 'color': 'white'})
