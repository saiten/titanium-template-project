_             = require 'underscore'
fs            = require 'fs'
path          = require 'path'
async         = require 'async'
{spawn, exec} = require 'child_process'
stdout        = process.stdout

config = require('./config')

titanium_path = (target) ->
  version = config.titanium_version[target]
  "#{process.env.HOME}/Library/Application\ Support/Titanium/mobilesdk/osx/#{version}"

# ANSI Terminal Colors.
bold   = "\033[0;1m"
red    = "\033[0;31m"
green  = "\033[0;32m"
yellow = "\033[0;33m"
blue   = "\033[0;34m"
reset  = "\033[0m"

# output titanium log
titanium_log = (data) ->
  data = data.toString().replace(/^\s*\n/g, '')
  lines = data.split(/\n/)
  for line in lines
    continue unless line.length > 0
    if line.match(/\[INFO\]/)
      stdout.write reset + green + line
    else if line.match(/\[TRACE\]/)
      stdout.write reset + blue + line
    else if line.match(/\[DEBUG\]/)
      stdout.write reset + blue + line
    else if line.match(/\[WARN\]/)
      stdout.write reset + yellow + line
    else if line.match(/\[ERROR\]/)
      stdout.write reset + red + line
    else
      stdout.write line
    stdout.write "\n"

  stdout.write reset

# Handle error and kill the process.
onerror = (err) ->
  if err
    process.stdout.write "#{red}#{err.stack}#{reset}\n"
    process.exit -1

# compile src
compile_coffee = (watch = false, callback = (code, signal) ->) ->
  args = ['-c', '-o', 'Resources/src', 'src']
  args.unshift '-w' if watch

  cmd = spawn("coffee", args)
  cmd.stdout.on "data", (data) -> stdout.write green + data + reset
  cmd.stderr.on "data", (data) -> stdout.write red + data + reset
  cmd.on "exit", callback
  cmd.on "error", onerror

# create i18n files
create_i18n_files = (callback = (err) ->) ->
  i18n_dir = './i18n'
  strings_file = './strings.coffee'

  if path.existsSync(strings_file)
    xmlbuilder = require 'xmlbuilder'

    strings = require strings_file
    resources = {}

    for name, langs of strings
      for lang, val of langs
        unless resources[lang]?
          resources[lang] = xmlbuilder.create().begin('resources', { 'version': '1.0' })
        resources[lang].ele('string').att('name', name).txt(val)

    write_xml = (lang, callback) ->
      i18n_lang_dir = path.join(i18n_dir, lang)
      unless path.existsSync(i18n_lang_dir)
        console.log "create directory : #{i18n_lang_dir}"
        err = fs.mkdirSync(i18n_lang_dir)
        return callback(err) if err?

      xml = resources[lang].doc().toString({ pretty: true })
      fs.writeFile path.join(i18n_lang_dir, 'strings.xml'), xml, (err) ->
        if err?
          callback(err)
        else
          callback()

    async.forEach _.keys(resources), write_xml, (err) ->
      if err?
        callback(err)
      else
        callback()
  else
    callback 0, null

# watch to change
watch_sources = (callback = (code, signal) ->) ->
  cmd = spawn("guard", [])
  cmd.stdout.on "data", (data) -> stdout.write green + data + reset
  cmd.stderr.on "data", (data) -> stdout.write red + data + reset
  cmd.on "exit", callback
  cmd.on "error", onerror

# build application environment
build_app = (options, callback = (code, signal) ->) ->
  compile_coffee false, (code) ->
    unless code is 0
      stdout.write red + "compile failed" + reset + "\n"
      callback(code)

    stdout.write green + "Compile source files ..." + reset + "\n"

    create_i18n_files (err) ->
      if err?
        stdout.write red + "create i18n files failed" + reset + "\n"
        callback(code)

      stdout.write green + "Create i18n files ..." + reset + "\n"
      callback(code)

# build application package
build_ipa = (options, callback = (code, signal) ->) ->
  build_type    = options?.buildType    ? 'install'
  env           = options?.environment  ? 'development'

  provisioning   = config.ios.provisioning[env]
  dist_name      = config.ios.distribution_name[env]
  target_version = config.ios.target_version

  xml2js = require 'xml2js'
  parser = new xml2js.Parser
  parser.addListener 'end', (tiapp) ->
    appid = tiapp.id
    name = tiapp.name
    appuuid = tiapp.guid

    args = [build_type, target_version, path.resolve("."), appid, name, provisioning, dist_name]
    args.push '.' if build_type is 'distribute'
    cmd = spawn("#{titanium_path('iphone')}/iphone/builder.py", args)
    cmd.stdout.on "data", titanium_log
    cmd.stderr.on "data", onerror
    cmd.on "error", onerror
    cmd.on "exit", callback

  parser.parseString fs.readFileSync("./tiapp.xml")

# ソース監視
task "watch", "Continously compile CoffeeScript to JavaScript", ->
  watch_sources()

#
# iPhone Task
#

# iPhone用環境構築
task "build:iphone", "build application for iPhone", (options) ->
  build_app {
    platform: 'iphone'
  }, (code) ->
    process.exit(-1) unless code is 0
    stdout.write green + "complete !" + reset + "\n"

# iPhoneシミュレータによる実行
task "run:iphone", "Test run application on iPhone simulator", (options) ->
  build_app {
    platform: 'iphone'
  }, (code) ->
    process.exit(-1) unless code is 0

    cmd = spawn("#{titanium_path('iphone')}/titanium.py", ["run", "--platform=iphone"])
    cmd.stdout.on "data", titanium_log
    cmd.stderr.on "data", onerror
    cmd.on "error", onerror

# 実機インストール用ビルド
task "install:iphone", "Install application for iPhone", (options) ->
  build_app {
    platform: 'iphone'
  }, (code) ->
    process.exit(-1) unless code is 0

    build_ipa {
      buildType: "install"
      environment: "development"
    }, (code) ->
      if code is 0
        stdout.write green + "install complete\n" + reset
      else
        stdout.write red + "install failed\n" + reset

# AppStore用ビルド
task "distribute:iphone", "Build application for iPhone", (options) ->
  build_app {
    platform: 'iphone'
  }, (code) ->
    process.exit(-1) unless code is 0

    build_ipa {
      buildType: "distribute"
      environment: "production"
      worldEdition: options.world_edition
    }, (code) ->
      if code is 0
        stdout.write green + "install complete\n" + reset
      else
        stdout.write red + "install failed\n" + reset

# buildディレクトリ掃除
task "clean:iphone", "Clean build directory for iPhone", (options) ->
  exec "rm -rf build/iphone/*", (err, out, err_out) ->
    unless err?
      stdout.write green + "clean success\n" + reset
    else
      stdout.write red + "clean failed\n" + reset

#
# Android Task
#

# android用環境構築
task "build:android", "build application for Android", (options) ->
  build_app {
    platform: 'android'
  }, (code) ->
    process.exit(-1) unless code is 0
    stdout.write green + "complete !" + reset + "\n"

task "run:android", "Test run application on Android Emulator", (options) ->
  build_app {
    platform: 'android'
  }, (code) ->
    process.exit(-1) unless code is 0

    cmd = spawn("#{titanium_path('android')}/titanium.py", ["run", "--platform=android"])
    cmd.stdout.on "data", titanium_log
    cmd.stderr.on "data", onerror

# androidエミュレータ実行
task "run:emulator", "Running android emulator", ->
  emu = spawn("#{titanium_path('android')}/android/builder.py", ["run-emulator", ".", android_sdk])
  emu.stdout.on "data", titanium_log
