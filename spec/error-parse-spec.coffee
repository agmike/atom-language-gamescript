LinterGameScript = require '../lib/linter-gamescript'

linter = new LinterGameScript()

describe "LinterGameScript::parse", ->
  it "should return 0 messages for an empty string", ->
    expect(linter.parse('')).toEqual([])

  it "should properly parse syntax error messages", ->
    expect(linter.parse('''
lse.log.library.gs(7) : function Print1 not declared in class Interface or derivative, line 7.
lse.log.library.gs(8) : function Print2 not declared in class Interface or derivative, line 8.
.. while compiling 'lse.log.library.gs'
OK (0 Errors, 0 Warnings)
'''))
      .toEqual([{
        type: 'error'
        text: 'function Print1 not declared in class Interface or derivative'
        filePath: 'lse.log.library.gs'
        range: [[6, 0], [6, 100]]
      }, {
        type: 'error'
        text: 'function Print2 not declared in class Interface or derivative'
        filePath: 'lse.log.library.gs'
        range: [[7, 0], [7, 100]]
      }, ])

  it "should properly parse file not found error message", ->
    expect(linter.parse('''
Could not read file (null) : alibrary.gs.
.. while compiling 'alibrary.gs'
.. while compiling 'lse.log.library.gs'
OK (0 Errors, 0 Warnings)
'''))
      .toEqual([{
        type: 'error'
        text: 'could not read file `alibrary.gs`'
      }])

  it "should properly parse parse error message", ->
    expect(linter.parse('''
lse.log.library.gs(9) : parse error, line 9
.. while compiling 'lse.log.library.gs'
OK (0 Errors, 0 Warnings)
'''))
      .toEqual([{
        type: 'error'
        text: 'parse error'
        filePath: 'lse.log.library.gs'
        range: [[8, 0], [8, 100]]
      }])
