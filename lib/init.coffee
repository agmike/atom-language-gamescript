{CompositeDisposable} = require 'atom'

module.exports =
  config:
    trainzUtilPath:
      type: 'string'
      default: ''
      description: 'Path to TrainzUtil executable.'
    scriptsPath:
      type: 'string'
      default: ''
      description: 'Path to standard scripts.'
    includePath:
      type: 'array'
      default: []
      description: 'Additional include directories'
      items:
        type: 'string'
    outputPath:
      type: 'string'
      default: 'out'
      description: 'Output path'

  activate: ->
    console.log 'Language-GameScript: package loaded,
                ready to get initialized by AtomLinter.'

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.config.observe 'language-gamescript.trainzUtilPath', (trainzUtilPath) =>
      @trainzUtilPath = trainzUtilPath

    @subscriptions.add atom.config.observe 'language-gamescript.scriptsPath', (scriptsPath) =>
      @scriptsPath = scriptsPath

    @subscriptions.add atom.config.observe 'language-gamescript.includePath', (includePath) =>
      @includePath = includePath

    @subscriptions.add atom.config.observe 'language-gamescript.outputPath', (outputPath) =>
      @outputPath = outputPath

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    LinterGameScript = require('./linter-gamescript')
    @provider = new LinterGameScript()
    return {
      grammarScopes: ['source.gamescript']
      scope: 'project'
      lint: @provider.lint
      lintOnFly: false
    }
