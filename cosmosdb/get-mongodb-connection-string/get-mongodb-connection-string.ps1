# Set the Azure resource group name and location
$resourceGroupName = "myResourceGroup"
$resourceGroupLocation = "South Central US"

# Create the resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation

# Database name
$DBName = "testdb"

# Write and read locations and priorities for the database
$locations = @(@{"locationName"="South Central US"; 
                 "failoverPriority"=0}, 
               @{"locationName"="North Central US"; 
                  "failoverPriority"=1})

# Consistency policy
$consistencyPolicy = @{"defaultConsistencyLevel"="BoundedStaleness"; 
                       "maxIntervalInSeconds"="10"; 
                       "maxStalenessPrefix"="200"}

# DB properties
$DBProperties = @{"databaseAccountOfferType"="Standard"; 
                  "kind"="MongoDB";
                  "locations"=$locations; 
                  "consistencyPolicy"=$consistencyPolicy}

# Create the database
New-AzureRmResource -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
                    -ApiVersion "2015-04-08" `
                    -ResourceGroupName $resourceGroupName `
                    -Location $resourceGroupLocation `
                    -Name $DBName `
                    -PropertyObject $DBProperties

# Retrieve a connection string that can be used by a MongoDB client
Invoke-AzureRmResourceAction -Action listConnectionStrings `
    -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
    -ApiVersion "2015-04-08" `
    -ResourceGroupName $resourceGroupName `
    -Name $DBName