function rattler (){

    local pipaction="$1"
    local pyversion="$2"

    if [[$pipaction == 'shortlist']]; then
        echo install sync rm sca activate coverag
        return
    fi


    if [[ $pipaction == 'rm' ]]; then
        echo 'Removing Virtual Environment'
        pyenv exec pipenv --rm
        return
    fi

    if [[ $pipaction == 'activate' ]]; then
        echo 'Activating Environment'
        source ./.venv/bin/activate
        return
    fi

    if [[ $pipaction == 'sca' ]]; then
        echo 'Running Static Code Analysis'
        mypy src/ --ignore-missing-imports
        pylint src/
        pyflakes src/
        pycodestyle src/ --max-line-length 100
        bandit -r src/ -c ./pyproject.toml
        return
    fi

    if [[ $pipaction == 'coverage' ]]; then
        echo 'Running Code Coverage'
        pytest --cov-report html --cov src/ tests/
        open ./htmlcov/index.html
        return

    fi

    if [[ $pipaction == 'install' && $pyversion == 'sca' ]]; then
            source ./.venv/bin/activate
            pipenv install mypy pycodestyle pytest assertpy pyflakes bandit pytest-cov pylint --dev
            return
    fi

    if [[ $pipaction == 'install' || $pipaction == 'sync' ]]; then
        if [[ -z $pyversion ]]; then
            pyenv exec pipenv $pipaction --dev
        else
            pyenv exec pipenv $pipaction --python $pyversion --dev
        fi
        chmod +x ./.venv/bin/activate
        source ./.venv/bin/activate
        pip install pipenv
        return
    fi
}
