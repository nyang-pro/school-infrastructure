Import-Module ADDSDeployment

$PasswordDSRM = Read-Host "Password DSRM" -AsSecureString

Install-ADDSForest `
    -DomainName "ad.kiformatou.fr" `
    -DomainNetbiosName "KIFORMATOU" `
    -InstallDns `
    -SafeModeAdministratorPassword $PasswordDSRM
