baseWin = Ti.UI.createWindow()

nav = Ti.UI.iPhone.createNavigationGroup()
baseWin.add nav

rootWin = Ti.UI.createWindow
  title: L("APP_TITLE")
  backgroundColor: 'white'

label = Ti.UI.createLabel
  text: "hello world !"

rootWin.add label

nav.window = rootWin
baseWin.open()