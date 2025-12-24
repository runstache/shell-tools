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

function uv_install_sca {

  uv_check_active
  Write-Host -ForegroundColor White 'Installing Dev Testing Tools'
  uv add --active --dev mypy pytest assertpy pytest-cov 
}

function uv_run_mypy {
  uv_check_active
  Write-Host "Running MyPy..."
  uv run --locked mypy .
}


function uv_run_pytest_coverage {
  uv_check_active
  Write-Host "Running PyTest with Coverage..."
  uv run --locked pytest --cov-report html --cov; .\htmlcov\index.html
}

function uv_activate_environment {
  Write-Host "Activating Python Environment"
  ./.venv/Scripts/activate

}


function uv_run_sca {

  uv_check_active
  Write-Host -ForegroundColor White 'Running SCA Checks on '$root
  uv_run_mypy
  uvx ruff check
  
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

- lint: Executes Ruff Linting and Checks on the current project

- help: Displays this message.
"@
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
      [ValidateSet("sca", "coverage", "activate", "rm", "install", "sync", "help", "lint")]$pipcommand,
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

  if ($pipcommand -eq "lint") {
    uvx ruff format
    uvx ruff check --fix
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
    uv sync --active --all-groups --all-packages --upgrade
    return
  }
  uv sync --active --all-groups --all-packages
  return

}
