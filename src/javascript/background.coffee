console.log '----------bg-----------'

chrome.browserAction.onClicked.addListener (tab) ->
  #chrome.tabs.executeScript null, file: 'javascript/icon_click.js'
  chrome.tabs.query active: true, currentWindow: true, (tabs) ->
    chrome.tabs.sendMessage tabs[0].id, type: "hello", name: 'sam', (response) ->
      console.log response

$ ->
  $("#cb_active").click ()->
    if $(this).is(":checked")
      $("#filter").removeAttr('disabled')
    else
      $("#filter").attr('disabled', 'disabled')