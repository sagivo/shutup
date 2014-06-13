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
    $("h5").text('sam!')
