console.log '----------bg-----------'
#localStorage.clear()

getSettings = ->  
  settings = localStorage.getItem('settings')
  if settings
    return JSON.parse(settings)
  else
    settings = {enabled:true}
    localStorage.setItem('settings', JSON.stringify(settings))
    settings 
  

chrome.browserAction.onClicked.addListener (tab) ->
  #chrome.tabs.executeScript null, file: 'javascript/icon_click.js'
  chrome.tabs.query active: true, currentWindow: true, (tabs) ->
    chrome.tabs.sendMessage tabs[0].id, type: "hello", name: 'sam', (response) ->
      console.log response

chrome.extension.onMessage.addListener (request, sender, cb) ->
  if request.type == 'getSettings'
    cb getSettings()

$ ->
  settings = getSettings()
  #init  
  if settings.enabled
    $("#options").show(); $("#cb_active").attr('checked', 'checked')
  else
    $("#options").hide();  $("#cb_active").removeAttr('checked')
  $("#filter").val(settings.filter)
  #clicks
  $("#cb_active").click ->
    if $("#cb_active").is(":checked")      
      $("#options").slideDown()
    else
      $("#options").slideUp()
    setSettings(enabled: $("#cb_active").is(":checked"))
  $("#btn_filetr").click ->
    setSettings filter: $("#filter").val()


setSettings = (set)->  
  localStorage.setItem( 'settings', JSON.stringify($.extend(getSettings(), set)) )