# Reference: Az.CosmosDB | https://docs.microsoft.com/powershell/module/az.cosmosdb
# --------------------------------------------------
# Purpose
# Create Cosmos SQL API account with firewall
# --------------------------------------------------
Function New-RandomString{Param ([Int]$Length = 10) return $(-join ((97..122) + (48..57) | Get-Random -Count $Length | ForEach-Object {[char]$_}))}
# --------------------------------------------------
$uniqueId = New-RandomString -Length 7 # Random alphanumeric string for unique resource names
$apiKind = "GlobalDocumentDB"
# --------------------------------------------------
# Variables - ***** SUBSTITUTE YOUR VALUES *****
$locations = @("East US", "West US") # Regions ordered by failover priority
$resourceGroupName = "cosmos" # Resource Group must already exist
$accountName = "cdb-$uniqueId" # Must be all lower case
$consistencyLevel = "Session"
$ipFilter = @("10.0.0.0/8", "11.0.1.0/24")
$allowAzureAccess = $true # Allow access to Azure networks and portal
# --------------------------------------------------

if ($true -eq $allowAzureAccess) {
    $ipFilter += "0.0.0.0"
}

# Account
Write-Host "Creating account $accountName"
$account = New-AzCosmosDBAccount -ResourceGroupName $resourceGroupName `
	-Location $locations -Name $accountName -ApiKind $apiKind `
    -DefaultConsistencyLevel $consistencyLevel -IpRangeFilter $ipFilter
