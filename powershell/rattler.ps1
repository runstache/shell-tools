function run_checkov {
  param (
      [Parameter(Position = 0, ValueFromRemainingArguments)]
      [String[]]$Parameters
  )
  $checkov_cmd = Get-Command * | Where-Object Name -Like 'checkov*'
  if ($checkov_cmd) {
      & python -x $($checkov_cmd.Path) -d .\cdk.out\
  }
  else {
      Write-Host -ForegroundColor Red 'Unable to locate checkov.cmd. (Is your .venv active?)'
  }
}

function installSca() {

  $pipenv_cmd = Get-Command * | Where-Object Name -Like 'pipenv*'

  if (!$pipenv_cmd) {
      Write-Host -ForegroundColor Red 'Unable to locate pipenv command. Activating Environment..'
      activateEnvironment
  }

  Write-Host -ForegroundColor White 'Installing Dev Testing Tools'
  pipenv install --dev pytest pytest-cov assertpy mypy pyflakes pylint pycodestyle bandit
  pipenv install sbom-html --dev --index=artifactory
}

function runMypy($root) {
  Write-Host "Running MyPy..."
  mypy $root/ --ignore-missing-imports
}

function runPylint($root) {
  Write-Host "Running Pylint..."
  pylint $root/ 
}

function runPyflakes($root) { 
  Write-Host "Running Pyflakes..."
  pyflakes $root/ 
}

function runPycodestyle($root) { 
  Write-Host "Running PyCodeStyle..."
  pycodestyle $root/ --max-line-length=100 
}

function runBandit($root) { 
  Write-Host "Running Bandit..."
  bandit $root/ -r -c ./pyproject.toml 
}

function runPyTestCoverage {
  $root = (root_folder)
  Write-Host "Running PyTest with Coverage..."
  pytest --cov=$root .\tests\ --cov-report=html; .\htmlcov\index.html 

}

function activateEnvironment {
  Write-Host "Activating PipEnv Environment"
  ./.venv/Scripts/activate

}


function run_sca {
  $pipenv_cmd = Get-Command * | Where-Object Name -Like 'pipenv*'

  if (!$pipenv_cmd) {
      Write-Host -ForegroundColor Red 'Unable to locate pipenv command. Activating Environment..'
      activateEnvironment
  }

  $root = (root_folder)
  Write-Host -ForegroundColor White 'Running SCA Checks on '$root
  runMypy($root)
  runPylint($root)
  runPycodestyle($root)
  runPyflakes($root)
  runBandit($root)

}

function py_me_help() {
  Write-Host @"
The following Operations are available through the pytool commandlet:

- install: Creates a new Pipfile and .env file if they do not exist. If they are present, the dependencies are installed for the provided python version. The value `"sca`" can also be used
for the python version and all Static Code Analysis dependencies will be installed.

- sync: Performs a PipEnv Sync operation for the specified Python version.

- activate: Activates the Virtual Environment through PipEnv

- rm: Removes the Virtual Environment through PipEnv

- sca: Executes the Static Code analysis operations

- coverage: Executes PyTest with Coverage Report. Opens the Report when completed.

- help: Displays this message.
"@
}

function root_folder() {
  $dirs = @(Get-ChildItem . -Name -Directory -Exclude .*,config,deployment,src,tests,cdk.out,libs)
  if ($dirs.Length -eq 1) {
    return $dirs[0]
  }
  return "src"
  
}
 

function rattler {
  param(
      [ValidateSet("sca", "coverage", "activate", "rm", "install", "sync", "help")]$pipcommand,
      $pyversion
  )


  #$pipcommand = $Parameters[0]
  #$pyversion = $Parameters[1]

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
      pyenv exec pipenv --rm
      return
  }

  if ($pipcommand -eq "activate") {
      activateEnvironment
      return
  }
  
  if ($pipcommand -eq "install" -And $pyversion -eq "sca") {
      installSca
      return
  }


  $env_file = @"
MAVEN_REPO_USER=`"$env:MAVEN_REPO_USER`"
MAVEN_REPO_PASS=`"$env:MAVEN_REPO_PASS`"
"@


  if ($null -eq $env:ARTIFACTORY_URL) {
    $start_pip_file = "[[source]]`r`nurl = `"https://pypi.python.org/simple`"`r`nverify_ssl = true`r`nname = `"pypi`"`r`n`r`n" +    
    "[packages]`r`n`r`n" +
    "[dev-packages]`r`n`r`n"
  } else {
    $start_pip_file = "[[source]]`r`nurl = `"https://pypi.python.org/simple`"`r`nverify_ssl = true`r`nname = `"pypi`"`r`n`r`n" +
    "[[source]]`r`nurl = `"https://`$MAVEN_REPO_USER:`${MAVEN_REPO_PASS}@$env:ARTIFACTORY_URL`"`r`nverify_ssl = true`r`nname = `"artifactory`"`r`n`r`n" +
    "[packages]`r`n`r`n" +
    "[dev-packages]`r`n`r`n"

  }

  
  if (!(Test-Path ".\.env")) {
      if ($null -ne $env:ARTIFACTORY_URL) {
        Out-File -FilePath ".\.env" -InputObject $env_file
      }
  }
  else {
      Write-Host -ForegroundColor Red "Environment File Exists."
  }

  if (!(Test-Path ".\Pipfile")) {
      Out-File -FilePath ".\Pipfile" -InputObject $start_pip_file
  }
  else {
      Write-Host -ForegroundColor Red "Pipfile Detected."
  }


  if ($pyversion) {
      pyenv exec pipenv $pipcommand --dev --python $pyversion
      ./.venv/Scripts/activate
      pip install pipenv

  }
  else {
      pyenv exec pipenv $pipcommand --dev
      ./.venv/Scripts/activate
      pip install pipenv
  }


}
