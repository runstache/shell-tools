function uv_check_active() {
  if (!$env:VIRTUAL_ENV) {
    uv_activate_environment
  }
}

function uv_run_checkov {
  param (
      [Parameter(Position = 0, ValueFromRemainingArguments)]
      [String[]]$Parameters
  )

  uv_check_active

  $checkov_cmd = Get-Command * | Where-Object Name -Like 'checkov*'
  if ($checkov_cmd) {
      & python -x $($checkov_cmd.Path) -d .\cdk.out\
  }
  else {
      Write-Host -ForegroundColor Red 'Unable to locate checkov.cmd. (Is your .venv active?)'
  }
}

function uv_install_sca() {

  uv_check_active
  Write-Host -ForegroundColor White 'Installing Dev Testing Tools'
  uv add --dev pytest pytest-cov assertpy mypy pyflakes pylint pycodestyle bandit flake8  
}

function us_run_mypy($root) {
  uv_check_active
  Write-Host "Running MyPy..."
  uv run mypy $root/ --ignore-missing-imports
}

function uv_run_pylint($root) {
  uv_check_active
  Write-Host "Running Pylint..."
  uv run pylint $root/ 
}

function uv_run_pyflakes($root) { 
  uv_check_active
  Write-Host "Running Pyflakes..."
  uv run pyflakes $root/ 
}

function uv_run_pycodestyle($root) { 
  uv_check_active
  Write-Host "Running PyCodeStyle..."
  uv run pycodestyle $root/ --max-line-length 100 
}

function uv_run_bandit($root) { 
  uv_check_active
  Write-Host "Running Bandit..."
  uv run bandit $root/ -r -c ./pyproject.toml 
}

function uv_run_pytest_coverage {
  uv_check_active
  $root = (uv_root_folder)
  Write-Host "Running PyTest with Coverage..."
  uv run pytest --cov=$root .\tests\ --cov-report=html; .\htmlcov\index.html 

}

function uv_run_flake8($root) {  
  uv_check_active
  Write-Host "Running Flake8..."
  uv run flake8 $root/ --max-line-length 100

}

function uv_activate_environment {
  Write-Host "Activating Python Environment"
  ./.venv/Scripts/activate

}


function uv_run_sca {

  uv_check_active
  $root = (uv_root_folder)
  Write-Host -ForegroundColor White 'Running SCA Checks on '$root
  uv_run_mypy($root)
  uv_run_flake8($root)
  uv_run_pylint($root)
  uv_run_pycodestyle($root)
  uv_run_pyflakes($root)
  uv_run_bandit($root)

}

function mamba_help() {
  Write-Host @"
The following Operations are available through the mamba commandlet:

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

function uv_root_folder() {

  $source_folder = 'src'
  if (-Not (Test-Path 'src')) {
    $source_folder = (Get-ChildItem -Filter __init__.py -Recurse -Depth 1)[0].Directory.Name
  }
  return $source_folder
  
}

function uv_add_cdk() {
  uv add aws-cdk-lib constructs boto3
  uv add checkov --dev
}

function uv_setup_environment() {
  if (!(Test-Path ".\pyproject.toml")) {
    Write-Host "Adding Project Setup.."
    uv init --bare
  }

  if (!(Test-Path ".\.venv")) {
    Write-Host "Creating Virtual Environment" -ForegroundColor White
    uv venv .venv
    uv_check_active
  }
  return
}
 

function mamba {
  param(
      [ValidateSet("sca", "coverage", "activate", "rm", "install", "sync", "help")]$pipcommand,
      $pyversion
  )

  if ($pipcommand -eq "help") {
      mamba_help
      return
  }

  if ($pipcommand -eq "sca") {
      uv_run_sca
      return
  }

  if ($pipcommand -eq "coverage") {
      uv_run_pytest_coverage
      return
  }

  if ($pipcommand -eq "rm") {
      Remove-Item -Path .\.venv -Recurse
      return
  }

  if ($pipcommand -eq "activate") {
      uv_check_active
      return
  }

  if ($pipcommand -eq "install" -And $pyversion -eq "cdk") {
    uv_add_cdk
    return
  }
  
  if ($pipcommand -eq "install" -And $pyversion -eq "sca") {
      uv_install_sca
      return
  }

  if ($pyversion) {
    uv python pin $pyversion
  }

  uv_setup_environment
  if ($pipcommand -eq "install") {
    uv sync --active --all-groups --upgrade
    return
  }
  uv sync --active --all-groups
  return

}
