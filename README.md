# GameScript support in Atom

Add syntax highlighting snippets, and lints via `trainzutil compile` to GameScript files in Atom.

GameScript is a scripting language used in Trainz Simulator.

![Example](http://i.imgur.com/IRoIg7w.png)

## Lint

[linter](https://atom.io/package/linter) is required for lint feature.
To enable you need to specify path to `TrainzUtil` and `scripts` folder of your
Trainz installation.

You can also specify additional include directories if you are using `script-include`
feature to include scripts from other assets.

By using a package like [project-manager](https://atom.io/packages/project-manager)
you can manage different include paths for different projects, for example:
```coffeescript
"lse-log":
  title: "lse-log"
  group: "Trainz"
  paths: [
    "D:\\TrainzDev\\lse-log"
  ]
  settings:
    "language-gamescript.includePath": ["D:\\TrainzDev\\lse\\src", "D:\\TrainzDev\\lse-test\\src"]
```
Now invoking `Project Manager: Reload Project Settings` command will set the include paths
as you specified for this project.

## Trainz: A New Era Note

TrainzUtil bundled with TANE currently does not support `compile` command. You will need
prior version of Trainz for lints to work.
