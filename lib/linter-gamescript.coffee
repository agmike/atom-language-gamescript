fs = require 'fs'
path = require 'path'
{BufferedProcess} = require 'atom'
{XRegExp} = require 'xregexp'



class LinterGameScript
  lintProcess: null

  lint: (textEditor) =>
    return new Promise (resolve, reject) =>
      results = []
      file = textEditor.getPath()
      curDir = path.dirname file
      command = @config 'trainzUtilPath'
      scriptsPath ='-i' +  @config 'scriptsPath'
      includePath = (@config('includePath') || []).map((p) -> '-i' + p)
      args = ['compile', file, scriptsPath].concat includePath
      options = {cwd: curDir}

      if !command
        resolve []
        return

      stdout = (data) ->
        results += data
      stderr = (err) ->
        results += err

      exit = (code) =>
        if (code is 0)
          resolve []
        messages = @parse results
        messages.forEach (message) ->
          if message.filePath && !(path.isAbsolute message.filePath)
            message.filePath = path.join curDir, message.filePath
        resolve messages

      @lintProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
      @lintProcess.onWillThrowError ({error, handle}) ->
        atom.notifications.addError "Failed to run TrainzUtil",
          detail: "#{error.message}"
          dismissable: true
        handle()
        resolve []


  couldNotReadFilePattern: XRegExp('^Could not read file \\(null\\) : (?<file>.+)\\.$', 'm')
  errorPattern: XRegExp('^\n?(?<file>[^(]+)\\((?<line>\\d+)\\) : (?<text>[^,]+), line \\d+\\.?$', 'm')
  # FIXME determine why extra newline is added after ^


  parse: (results) ->
    messages = []
    XRegExp.forEach results, @couldNotReadFilePattern, (match) ->
      messages.push {
        type: 'error'
        text: "could not read file `#{match.file}`"
      }
    XRegExp.forEach results, @errorPattern, (match) ->
      messages.push {
        type: 'error'
        text: match.text
        filePath: match.file
        range: [[match.line - 1, 0], [match.line - 1, 100]]
      }
    return messages


  config: (key) ->
    atom.config.get "language-gamescript.#{key}"



module.exports = LinterGameScript
