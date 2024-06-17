function getCredentials($aws_profile) {
  $creds = aws configure export-credentials --profile $aws_profile
  if ($creds -match "error") {
      Write-Error "Invalid or expired SSO session."
      return
  }

  $aws_creds = (aws configure export-credentials --profile $aws_profile | ConvertFrom-Json)
  $access_key = $aws_creds.AccessKeyId
  $secret_key = $aws_creds.SecretAccessKey
  $token = $aws_creds.SessionToken


  $TempFile = (Join-Path $ENV:USERPROFILE "temp.html")

  Write-Output @"
<html>
<script>

</script>
<body>
  <h2>$aws_profile</h2>
  <table>
      <tr>
          <td><button type="button" id="copy_key_name" onclick="navigator.clipboard.writeText('AWS_ACCESS_KEY_ID')">AWS_ACCESS_KEY_ID</button></td>
          <td><input type="text" id="aws_key" value="$access_key" />
              <button type="Button" id="copy_key_value" onclick="navigator.clipboard.writeText(document.getElementById('aws_key').value)">Copy</button></td>
      </tr>
      <tr>
          <td><button type="button" id="copy_secret_name" onclick="navigator.clipboard.writeText('AWS_SECRET_ACCESS_KEY')">AWS_SECRET_ACCESS_KEY</button></td>
          <td><input type="text" id="aws_secret" value="$secret_key">
          <button type="Button" id="copy_secret_value" onclick="navigator.clipboard.writeText(document.getElementById('aws_secret').value)">Copy</button></td>
      </tr>
      <tr>
          <td><button type="button" id="copy_token_name" onclick="navigator.clipboard.writeText('AWS_SESSION_TOKEN')">AWS_SESSION_TOKEN</button></td>
          <td><input type="text" id="aws_token" value="$token">
          <button type="Button" id="copy_token_value" onclick="navigator.clipboard.writeText(document.getElementById('aws_token').value)">Copy</button></td>
      </tr>
  </table>
</body>
</html>
"@ | Out-File -FilePath $TempFile -Encoding utf8  
  Start-Process $TempFile
  Start-Sleep -Seconds 1
  Remove-Item $TempFile
  return
}

function loadBastion($name) {

  if (!(Test-Path "$ENV:USERPROFILE\.aws\bastions.json")) {
    Write-Host -ForegroundColor Red "Bastions File not Present!"
    return $null
  }


  $config = Get-Content "$ENV:USERPROFILE\.aws\bastions.json" | ConvertFrom-Json
  if ([bool]$config.PSObject.Properties[$name]) {
      return $config.$name
  }
  return $null
}

function aws_connect {

  param(
      [Parameter(Position = 0, ValueFromRemainingArguments)]
      [String[]]$Parameters
  )

  $aws_command = $Parameters[0]
  $aws_profile = $Parameters[1]

  if ($aws_command -eq "login") {
      Write-Host -ForegroundColor White 'Refreshing AWS SSO Connection'
      aws sso login --profile de-prd
      return
  }

  if ($aws_command -eq "creds") {
      Write-Host -ForegroundColor White 'Generating AWS Temp Credentials'
      getCredentials($aws_profile)
      return
  }

  if ($aws_command -eq "bastion") {


      if ($aws_profile -eq "list") {
          $config = Get-Content "$ENV:USERPROFILE\.aws\bastions.json" | ConvertFrom-Json
          Write-Host -ForegroundColor White 'Bastions Configured'
          $config|Get-Member -MemberType NoteProperty|Select-Object Name
          return
      }


      Write-Host -ForegroundColor White "Connecting to Bastion: $aws_profile"
      $config = loadBastion($aws_profile)
      if ($null -eq $config) {
          Write-Host -ForegroundColor Red 'Bastion Configuration not Found.'
          return
      }

      $stack_name=$config.stackName
      $environment=$config.environment
      $sourcePort=$config.sourcePort
      $destinationPort=$config.destinationPort
      $remoteHost=$config.host

      $filter = @( "Name=tag:aws:cloudformation:stack-name,Values=$stack_name","Name=tag:Environment,Values=$environment" )
          
      $hostBastion = aws ec2 describe-instances --filter @filter `
                                                   --query 'Reservations[*].Instances[*].InstanceId' `
                                                   --output text `
                                                   --profile $config.profile
          

      $parameters = @( "host=$remoteHost","portNumber=$destinationPort","localPortNumber=$sourcePort" )
      $paramList=$parameters -join ","
      aws ssm start-session --target $hostBastion `
                            --document-name AWS-StartPortForwardingSessionToRemoteHost `
                            --parameters  $paramList `
                            --profile $config.profile
      return

  }
}