param([string] $AzureSecretsFile, [string] $ExecTag)


function Main {
#    param (
#        $AzureSecretsFile,
#	$ExecTag
#    )

	Write-Host "Input params: SecreteFile $AzureSecretsFile executiontag $ExecTag"
	$XmlSecrets = ""
	if (![String]::IsNullOrEmpty($AzureSecretsFile) -and (Test-Path -Path $AzureSecretsFile) -eq $true) {
		$XmlSecrets = ([xml](Get-Content $AzureSecretsFile))
	} else {
		Write-Host "Error: Please provide value for -AzureSecretsFile"
	}

	if ($XmlSecrets) {
		$dataSource = $XmlSecrets.secrets.DatabaseServer
		#$dbuser = $XmlSecrets.secrets.DatabaseUser
		#$dbpassword = $XmlSecrets.secrets.DatabasePassword
		$dbuser = 'msftguest'
		$dbpassword = 'lisap@ssw0rd'
		$database = $XmlSecrets.secrets.DatabaseName

		if ($dataSource -and $dbuser -and $dbpassword -and $database) {
			try
			{
				$SQLQuery = "select * from LISAv2Results_Test where ExecutionTag='Hotfix-test'" 
				#$SQLQuery = "select * from lis_distro_results" 
				Write-Host "SQLQuery:  $SQLQuery"
				$connectionString = "Server=$dataSource;uid=$dbuser; pwd=$dbpassword;Database=$database;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
				$connection = New-Object System.Data.SqlClient.SqlConnection
				$connection.ConnectionString = $connectionString
				$connection.Open()
				$command = $connection.CreateCommand()
				$command.CommandText = $SQLQuery
				$null = $command.executenonquery()
				$connection.Close()
			}
			catch
			{
				$line = $_.InvocationInfo.ScriptLineNumber
				$script_name = ($_.InvocationInfo.ScriptName).Replace($PWD,".")
				$ErrorMessage =  $_.Exception.Message
			}
		} else {
			Write-Host "Error: Database details are not provided. Results will not be uploaded to database!!"
		}
	} else {
		Write-Host "Error:Unable to send telemetry data to Azure. XML Secrets file not provided."
	}
}	

Main -AzureSecretsFile $AzureSecretsFile -ExecTag $ExecTag

