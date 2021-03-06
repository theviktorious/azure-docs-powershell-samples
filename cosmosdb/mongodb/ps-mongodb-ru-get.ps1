# Reference: Az.CosmosDB | https://docs.microsoft.com/powershell/module/az.cosmosdb
# --------------------------------------------------
# Purpose
# Get database or collection throughput
# --------------------------------------------------
# Variables - ***** SUBSTITUTE YOUR VALUES *****
$resourceGroupName = "cosmos" # Resource Group must already exist
$accountName = "myaccount" # Must be all lower case
$databaseName = "mydatabase" # Keyspace with shared throughput
$collectionName = "mycollection" # Table with dedicated throughput
# --------------------------------------------------

Write-Host "Get database shared throughput"
Get-AzCosmosDBMongoDBDatabaseThroughput -ResourceGroupName $resourceGroupName `
    -AccountName $accountName -Name $databaseName

Write-Host "Get collection dedicated throughput"
Get-AzCosmosDBMongoDBCollectionThroughput -ResourceGroupName $resourceGroupName `
    -AccountName $accountName -DatabaseName $databaseName `
    -Name $collectionName
