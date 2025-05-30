function rattler (){

    local pipaction=${1?:"Pip Action is required"}
    local pyversion="$2"

    root_folder="src"
    search_dir="."
    
    # Find the first subfolder with an __init__.py file, excluding certain folders
    for dir in $(find "$search_dir" -type d -maxdepth 1 -not -path "*tests*" -not -path "*.venv" -not -path "*venv*"); do;
        if [[ -f "$dir/__init__.py" ]]; then;
                root_folder=$dir
                break
        fi
    done

    if [[ $pipaction == 'rm' ]]; then;
        echo 'Removing Virtual Environment'

        if [[ ${VIRTUAL_ENV} ]]; then;
            deactivate
        fi

        if [[ -d './.venv/' ]]; then;
            rm -r .venv
        else;
            echo 'Virtual Environment not found.'
        fi
        return
    fi

    if [[ $pipaction == 'activate' ]]; then;
        echo 'Activating Environment'
        source ./.venv/bin/activate
        return
    fi

    if [[ $pipaction == 'sca' ]]; then;
        echo "Running Static Code Analysis - ${root_folder}"

        if [[ ! ${VIRTUAL_ENV} ]]; then;
            source ./.venv/bin/activate
        fi

        mypy $root_folder/ --ignore-missing-imports
        flake8 $root_folder/ --max-line-length 100
        pylint $root_folder/
        pyflakes $root_folder/
        pycodestyle $root_folder/ --max-line-length 100
        bandit -r $root_folder/ -c ./pyproject.toml
        return
    fi

    if [[ $pipaction == 'coverage' ]]; then;
        echo 'Running Code Coverage'

        if [[ ! ${VIRTUAL_ENV} ]]; then;
            source ./.venv/bin/activate
        fi

        pytest --cov-report html --cov $root_folder tests/
        open ./htmlcov/index.html
        return

    fi

    if [[ $pipaction == 'install' || $pipaction == 'sync' ]]; then;

        if [[ $pyversion == 'sca' ]]; then;
            echo 'Adding Static Code tools'

            if [[ ! ${VIRTUAL_ENV} ]]; then;
                source ./.venv/bin/activate
            fi
            uv add --active --dev mypy pycodestyle pytest assertpy pyflakes bandit pytest-cov pylint flake8
            return
        fi

        if [[ $pyversion == 'cdk' ]]; then;
            echo 'Adding AWS CDK Packages'

            if [[ ! ${VIRTUAL_ENV} ]]; then;
                source ./.venv/bin/activate
            fi

            uv add --active aws-cdk-lib constructs
            uv add --active --dev checkov
            return
        fi

        if [[ $pyversion ]]; then;
            uv python pin $pyversion
        fi

        if [[ ! -f './pyproject.toml' ]]; then;
            echo 'Creating new project'
            uv init --bare            
        fi

        if [[ ! -d './.venv' ]]; then;
            echo 'Setting up Virtual Environment'
            uv venv .venv
            source ./.venv/bin/activate
        else;
            if [[ ! ${VIRTUAL_ENV} ]]; then;
                echo 'Activating Virtual Environment'
                source ./.venv/bin/activate 
            fi
        fi

        if [[ $pipaction == 'install' ]]; then;
                uv sync --all-groups --upgrade
                return
        fi
        uv sync --all-groups
        return
    fi

}