import os, osproc, webgui, strutils


let app = newWebView(currentHtmlPath(), title = "Choosenim GUI", height = 666)


template justDoIt(command: string) =
  const
    style = """style="border: 1px solid white;""""
  let
    html = "<textarea class=\"output\" rows=12 readonly " & style & ">" & execProcess("choosenim --noColor " & command) & "</textarea>"
  app.js(app.addHtml("#versions", html, position=afterbegin))


template justDoItVersion(command: string) =
  const
    style = """style="border: 1px solid white; text-align: center; overflow: hidden;""""
  let
    html = "<textarea class=\"output\" rows=1 readonly " & style & ">" & execProcess("choosenim --noColor " & command) & "</textarea>"
  app.js(app.addHtml("#versions", html, position=afterbegin))


const selectVersion = """
<div style="border: 1px solid white; padding: 20px; text-align: center;">
  <p>Click on the version to <b>$1</b></p>
  <ul style="width: 300px; margin-left: auto; margin-right: auto;">
    $2
  </ul>
</div>
"""
proc versions(action: string) =
  const
    style = """style="background-color: white; cursor: pointer; padding: 5px; color: black; border-radius: 2px;""""
  var
    html: string
    avail: bool

  for line in execProcess("choosenim --noColor show").split("\n"):
    if line.contains("Versions:"):
      avail = true
      continue
    
    if not avail or line == "": # or (action == "select" and line.contains("*")):
      continue
    
    html.add("<p onclick=\"api.cn" & capitalizeAscii(action) & "Do(this.textContent)\" " & style & ">" & line.strip() & "</p>")

  app.js(app.addHtml("#versions", selectVersion.format(toUpperAscii(action), html), position=afterbegin))


proc install() =
  const
    style = """style="background-color: white; cursor: pointer; padding: 5px; color: black; border-radius: 2px;""""
  var
    html: string
    avail: bool

  for line in execProcess("choosenim --noColor versions").split("\n"):
    if line.contains("Available:"):
      avail = true
      continue
    
    if not avail or line == "": # or (action == "select" and line.contains("*")):
      continue
    
    html.add("<p onclick=\"api.cnInstallDo(this.textContent)\" " & style & ">" & line.strip() & "</p>")

  app.js(app.addHtml("#versions", selectVersion.format(toUpperAscii("install"), html), position=afterbegin))


app.bindProcs("api"):
  proc cnShow()               = justDoIt "show"
  proc cnListInstalled()      = justDoIt "versions --installed"
  proc cnListAll()            = justDoIt "versions"
  proc cnSelect()             = versions("select")
  proc cnSelectDo(s: string)  = justDoItVersion s.strip().multiReplace([("#", ""), ("*", ""), ("(latest)", "")])
  proc cnUpdate()             = versions("update")
  proc cnUpdateDo(s: string)  = justDoIt "update " & s.strip().multiReplace([("#", ""), ("*", ""), ("(latest)", "")])
  proc cnInstall()            = install()
  proc cnInstallDo(s: string) = justDoIt s.strip().multiReplace([("#", ""), ("*", ""), ("(latest)", "")])

versions("select")
app.run()
app.exit()