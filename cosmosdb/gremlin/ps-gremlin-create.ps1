# Reference: Az.CosmosDB | https://docs.microsoft.com/powershell/module/az.cosmosdb
# --------------------------------------------------
# Purpose
# Create Cosmos Gremlin API account, database, and graph with multi-master enabled,
# a database with shared thoughput, and a graph with dedicated throughput,
# and conflict resolution policy with last writer wins and custom resolver path
# --------------------------------------------------
Function New-RandomString{Param ([Int]$Length = 10) return $(-join ((97..122) + (48..57) | Get-Random -Count $Length | ForEach-Object {[char]$_}))}
# --------------------------------------------------
$uniqueId = New-RandomString -Length 4 # Random alphanumeric string for unique resource names
$apiKind = "Gremlin"
# --------------------------------------------------
# Variables - ***** SUBSTITUTE YOUR VALUES *****
$locations = @("East US", "West US") # Regions ordered by failover priority
$resourceGroupName = "cosmos" # Resource Group must already exist
$accountName = "cdb-gr-$uniqueId" # Must be all lower case
$consistencyLevel = "Session"
$tags = @{Tag1 = "MyTag1"; Tag2 = "MyTag2"; Tag3 = "MyTag3"}
$databaseName = "mydatabase"
$databaseRUs = 400
$graphName = "mygraph"
$graphRUs = 400
$partitionKeys = @("/myPartitionKey")
$conflictResolutionPath = "/myResolutionPath"
# --------------------------------------------------
# Account
Write-Host "Creating account $accountName"
# Gremlin not yet supported in New-AzCosmosDBAccount
# $account = New-AzCosmosDBAccount -ResourceGroupName $resourceGroupName `
    # -Location $locations -Name $accountName -ApiKind $apiKind -Tag $tags `
    # -DefaultConsistencyLevel $consistencyLevel `
    # -EnableMultipleWriteLocations
# --------------------------------------------------
# Account creation: use New-AzResource with property object
$azAccountResourceType = "Microsoft.DocumentDb/databaseAccounts"
$azApiVersion = "2019-12-12"
$azApiType = "EnableGremlin"

$azLocations = @()
$i = 0
ForEach ($location in $locations) {
    $azLocations += @{ locationName = "$location"; failoverPriority = $i++ }
}

$azConsistencyPolicy = @{
    defaultConsistencyLevel = "$consistencyLevel";
}

$azAccountProperties = @{
    capabilities = @( @{ name = "$azApiType" } );
    databaseAccountOfferType = "Standard";
    locations = $azLocations;
    consistencyPolicy = $azConsistencyPolicy;
    enableMultipleWriteLocations = "true";
}

New-AzResource -ResourceType $azAccountResourceType -ApiVersion $azApiVersion `
    -ResourceGroupName $resourceGroupName -Location $locations[0] `
    -Name $accountName -PropertyObject $azAccountProperties `
    -Tag $tags -Force

$account = Get-AzCosmosDBAccount -ResourceGroupName $resourceGroupName -Name $accountName
# --------------------------------------------------
# Powershell cmdlets for database and graph operations

# Database
$database = Set-AzCosmosDBGremlinDatabase -ResourceGroupName $resourceGroupName `
    -AccountName $accountName -Name $databaseName `
    -Throughput $databaseRUs

# Graph
$conflictResolutionPolicy = New-AzCosmosDBGremlinConflictResolutionPolicy `
    -Type LastWriterWins -Path $conflictResolutionPath

$graph = Set-AzCosmosDBGremlinGraph -ResourceGroupName $resourceGroupName `
    -AccountName $accountName -DatabaseName $databaseName `
    -Name $graphName -Throughput $graphRUs `
    -PartitionKeyKind Hash -PartitionKeyPath $partitionKeys `
    -ConflictResolutionPolicy $conflictResolutionPolicy
