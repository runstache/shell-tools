function checkActive() {
  if (!$env:VIRTUAL_ENV) {
    activateEnvironment
  }
}

function run_checkov {
  param (
      [Parameter(Position = 0, ValueFromRemainingArguments)]
      [String[]]$Parameters
  )

  checkActive

  $checkov_cmd = Get-Command * | Where-Object Name -Like 'checkov*'
  if ($checkov_cmd) {
      & python -x $($checkov_cmd.Path) -d .\cdk.out\
  }
  else {
      Write-Host -ForegroundColor Red 'Unable to locate checkov.cmd. (Is your .venv active?)'
  }
}

function installSca() {

  checkActive
  Write-Host -ForegroundColor White 'Installing Dev Testing Tools'
  uv add --dev pytest pytest-cov assertpy mypy pyflakes pylint pycodestyle bandit flake8  
}

function runMypy($root) {
  checkActive
  Write-Host "Running MyPy..."
  uv run mypy $root/ --ignore-missing-imports
}

function runPylint($root) {
  checkActive
  Write-Host "Running Pylint..."
  uv run pylint $root/ 
}

function runPyflakes($root) { 
  checkActive
  Write-Host "Running Pyflakes..."
  uv run pyflakes $root/ 
}

function runPycodestyle($root) { 
  checkActive
  Write-Host "Running PyCodeStyle..."
  uv run pycodestyle $root/ --max-line-length 100 
}

function runBandit($root) { 
  checkActive
  Write-Host "Running Bandit..."
  uv run bandit $root/ -r -c ./pyproject.toml 
}

function runPyTestCoverage {
  checkActive
  $root = (root_folder)
  Write-Host "Running PyTest with Coverage..."
  uv run pytest --cov=$root .\tests\ --cov-report=html; .\htmlcov\index.html 

}

function runflake8($root) {  
  checkActive
  Write-Host "Running Flake8..."
  uv run flake8 $root/ --max-line-length 100

}

function activateEnvironment {
  Write-Host "Activating Python Environment"
  ./.venv/Scripts/activate

}


function run_sca {

  checkActive
  $root = (root_folder)
  Write-Host -ForegroundColor White 'Running SCA Checks on '$root
  runMypy($root)
  runflake8($root)
  runPylint($root)
  runPycodestyle($root)
  runPyflakes($root)
  runBandit($root)

}

function py_me_help() {
  Write-Host @"
The following Operations are available through the pytool commandlet:

- install: Creates a new PyProject.toml if not present, sets up a virtual environment and installs with upgrade the dependencies of the project. Contains 
options for adding the Static Code analysis libraries and also AWS CDK through the sca option and cdk option of the Install command.

- sync: Creates a PyProject.toml and virtual environment if not present and syncs the dependencies without performing an upgrade for the defined version.

- activate: Activates the Virtual Environment

- rm: Removes the Virtual Environment

- sca: Executes the Static Code analysis operations

- coverage: Executes PyTest with Coverage Report. Opens the Report when completed.

- help: Displays this message.
"@
}

function root_folder() {

  $source_folder = 'src'
  if (-Not (Test-Path 'src')) {
    $source_folder = (Get-ChildItem -Filter __init__.py -Recurse -Depth 1)[0].Directory.Name
  }
  return $source_folder
  
}

function add_cdk() {
  uv add aws-cdk-lib constructs boto3
  uv add checkov --dev
}

function setupEnvironment() {
  if (!(Test-Path ".pyproject.toml")) {
    Write-Host "Adding Project Setup.."
    uv init --bare
  }

  if (!(Test-Path ".\.venv")) {
    Write-Host "Creating Virtual Environment" -ForegroundColor White
    uv venv .venv
    activateEnvironment
  }
  return
}
 

function mamba {
  param(
      [ValidateSet("sca", "coverage", "activate", "rm", "install", "sync", "help")]$pipcommand,
      $pyversion
  )

  if ($pipcommand -eq "help") {
      py_me_help
      return
  }

  if ($pipcommand -eq "sca") {
      run_sca
      return
  }

  if ($pipcommand -eq "coverage") {
      runPyTestCoverage
      return
  }

  if ($pipcommand -eq "rm") {
      Remove-Item -Path .\.venv -Recurse
      return
  }

  if ($pipcommand -eq "activate") {
      activateEnvironment
      return
  }

  if ($pipcommand -eq "install" -And $pyversion -eq "cdk") {
    add_cdk
    return
  }
  
  if ($pipcommand -eq "install" -And $pyversion -eq "sca") {
      installSca
      return
  }

  if ($pyversion) {
    uv python pin $pyversion
  }

  setupEnvironment
  if ($pipcommand -eq "install") {
    uv sync --active --all-groups --upgrade
    return
  }
  uv sync --active --all-groups
  return

}
