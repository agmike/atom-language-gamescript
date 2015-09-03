fs = require 'fs'
path = require 'path'
filewalker = require 'filewalker'
{BufferedProcess} = require 'atom'
{XRegExp} = require 'xregexp'



class LinterGameScript
  lintProcesses: []

  addProcess: (process) ->
    # console.log 'adding process'
    @lintProcesses.push(process) unless @lintProcesses.indexOf(process) >= 0

  removeProcess: (process) ->
    # console.log 'finished process'
    index = @lintProcesses.indexOf(process)
    @lintProcesses.splice(index, 1) unless index < 0

  lint: (textEditor) =>
    return new Promise (resolve, reject) =>
      # console.log 'lint start'

      command = @config 'trainzUtilPath'
      if !command
        resolve []
        return
      scriptsPath ='-i' +  @config 'scriptsPath'
      includePath = (@config('includePath') || [])
        .map (p) -> '-i' + p

      allMessages = []

      walkCount = 0;
      atom.project.getPaths().forEach (rootDirPath) =>
        # console.log 'project path: ' + rootDirPath
        walkCount += 1
        walker = filewalker(rootDirPath, { maxPending: (@config 'jobsCount'), matchRegExp: /\.gs$/ })
          .on("file", (filePath, fileStats, absPath) =>
            walker.pause()
            # console.log 'file: ' + absPath

            file = absPath
            curDir = path.dirname absPath
            outDir = '-p' + path.join rootDirPath, (@config 'outputPath'), 'gsl'
            args = ['compile', file, outDir, scriptsPath].concat includePath
            options = {cwd: curDir}

            results = ''
            stdout = (str) ->
              results += str
            stderr = (str) ->
              results += str

            exit = (code) =>
              walker.resume()
              # console.log 'exited process'
              # console.log 'results:\n' + results
              unless code is 0
                messages = @parse results
                messages.forEach (message) ->
                  if message.filePath && !(path.isAbsolute message.filePath)
                    message.filePath = path.join curDir, message.filePath
                allMessages.push messages...
              @removeProcess lintProcess
              if (walkCount is 0) && (@lintProcesses.length is 0)
                # console.log 'resolve'
                resolve @filter(allMessages)


            # console.log 'start ' + args
            lintProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
            @addProcess lintProcess
            lintProcess.onWillThrowError ({error, handle}) ->
              atom.notifications.addError "Failed to run TrainzUtil",
                detail: "#{error.message}"
                dismissable: true
              @removeProcess lintProcess
              handle()
          ).on('error', (e) ->
            console.log '[language-gamescript] error: ' + e.message
          ).on('done', ->
            walkCount -= 1
            # console.log 'done'
          ).walk()


  couldNotReadFilePattern: XRegExp('^Could not read file \\(null\\) : (?<file>.+)\\.$', 'm')
  errorPattern: XRegExp('^\n?(?<file>[^(]+)\\((?<line>\\d+)\\) : (?<text>.+?), line \\d+\\.?$', 'm')
  # FIXME determine why extra newline is added after ^


  parse: (results) ->
    messages = []

    XRegExp.forEach results, @couldNotReadFilePattern, (match) ->
      msg =
        type: 'error'
        text: "could not read file `#{match.file}`"
      messages.push msg

    XRegExp.forEach results, @errorPattern, (match) ->
      msg =
        type: 'error'
        text: match.text
        filePath: match.file
        range: [[match.line - 1, 0], [match.line - 1, 100]]
      messages.push msg

    return messages

  filter: (allMessages) ->
    messages = []
    getLine = (m) ->
      if m.range
        return m.range[0][0]
      undefined
    #toStr = (m) -> "message: '#{m.text}' at '#{m.file}':#{getLine(m)}"
    for msg in allMessages
      exists = false
      for existing in messages
        if existing.text == msg.text && existing.file == msg.file && getLine(existing) == getLine(msg)
          exists = true
          break
      if !exists
        messages.push msg
    return messages



  config: (key) ->
    atom.config.get "language-gamescript.#{key}"



module.exports = LinterGameScript
