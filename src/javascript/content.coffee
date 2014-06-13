settings = active:true
console.log 'content'

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  console.log 'msg'
  console.log (if sender.tab then "from a content script:" + sender.tab.url else "from the extension")
  if request.type == "hello"
    alert 'hi ' + request.name
  sendResponse status: "ok"
  true

$ ->
  if settings.active
    text = 'game of'
    $("a:contains('" + text + "'),p:contains('" + text + "'),span:contains('" + text + "')").each (i,e) ->
      $(e).attr('data-txt',$(e).text()).text('KABOOM').css({'background-color':'red', 'color': 'white'}).click ->
        $(this).text( $(this).attr('data-txt') )
    $("h5").text('sam4!!')
