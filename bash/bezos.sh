_bezos() {
    compadd login creds bastion list
}
compdef _bezos bezos

function credentials ($aws_profile){
    $creds = $(aws configure export-credentials --profile $aws_profile)
    if [[$creds == *'error'*]]; then
        echo "Invalid or expired SSO session, attempting re-login"
        aws sso login --profile $ACTIVE_PROFILE
        $creds = $(aws configure export-credentials --profile $aws_profile)
        if [[$creds =~ *"error"*]]; then
            echo "Unable to refresh SSO session."
            return
        fi        
    fi
    
  

    $aws_creds = $(aws configure export-credentials --profile $aws_profile)
    $access_key = $(jq $aws_creds '.AccessKeyId')
    $secret_key = $(jq $aws_creds '.SecretAccessKey')
    $token = $(jq $aws_creds '.SessionToken')
    $expiration = $(jq $aws_creds '.Expiration')

    export AWS_ACCESS_KEY_ID=$aws_creds
    export AWS_SECRET_ACCESS_KEY=$secret_key
    export AWS_DEFAULT_REGION='us-east-1'
    export AWS_SESSION_TOKEN=$token
    
}

function loadBastion ($name) {
    if [[test -f "$HOME/bastion.json"]]; then
        $config=$(jq --arg field $name '.[$field]' $HOME/bastion.json)
        return $config
    fi
    echo "Bastion Configuration Not Present"
    return
}

function bastionList (){
    echo "Bastions:"
    jq -r 'to_entries[] | "\(.key)"' $HOME/bastion.json
}



function login () {
    echo "Refreshing SSO Login..."
    aws sso login --profile $ACTIVE_PROFILE
}


function bezos (){
    local awsaction="$1"
    local awssubaction="$2"
    echo "$action $subaction"

    if [[ $awsaction == 'login' ]]; then
        $(login)
        return

    fi

    if [[ $awsaction == 'bastion' ]]; then
        if [[$awssubaction == 'list']]; then
            $(bastionList)
            return
        fi
        $(bastionConnect($subaction))
        return
    fi

    if [[ $awsaction == 'creds' ]]; then
        $(credentials($subaction))
        return
    fi
}