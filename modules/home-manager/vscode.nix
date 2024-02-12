{ pkgs, ... }:
{
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      mutableExtensionsDir = true;

      # Extensions
      extensions = (with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.vscode-pylance
        ms-python.black-formatter
        ms-vscode.makefile-tools
        golang.go
        charliermarsh.ruff
        bbenoist.nix
        redhat.vscode-yaml
      ]);

      userSettings = {
        # IDE
        "files.trimTrailingWhitespace" = true;
        "editor.formatOnSave" = true;
        "explorer.confirmDragAndDrop" = false;

        # Golang
        "go.formatTool" = "gofmt";
        "go.goroot" = "";
        "go.lintOnSave" = "workspace";
        "go.lintTool" = "golangci-lint";
        "go.lintFlags" = ["run" "--config=./.golangci.yml" "./..."];
        "go.vetOnSave" = "workspace";
        "go.coverOnSave" = true;
        "go.coverageDecorator"."type"= "gutter";
        "go.coverageDecorator"."coveredHighlightColor"= "rgba(64,128,128,0.5)";
        "go.coverageDecorator"."uncoveredHighlightColor"= "rgba(128,64,64,0.25)";
        "go.coverageDecorator"."coveredGutterStyle"= "blockgreen";
        "go.coverageDecorator"."uncoveredGutterStyle"= "blockred";
        "go.coverOnSingleTest"= true;

        # Python
        "[python]"."editor.formatOnType" = true;
        "[python]"."editor.defaultFormatter" = "ms-python.black-formatter";
        "[python]"."editor.formatOnSave" = true;
        "python.analysis.autoImportCompletions" = true;
        "python.analysis.diagnosticMode" = "workspace";
        "python.analysis.ignore" = ["cdk.out" "go/vendor" ".venv"];
        "ruff.format.args" = ["--config=./pyproject.toml"];
        "ruff.lint.args" = ["--config=./pyproject.toml"];
        "black-formatter.importStrategy" = "fromEnvironment";

        # Misc
        "[nix]"."editor.tabSize" = 2;
        "yaml.format.enable" = false;
        "[markdown]"."files.trimTrailingWhitespace" = false;
        "[env]"."editor.formatOnSave" = false;
      };
    };
}