#Create Function from Commandline
# https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-cli-csharp?tabs=azure-cli%2Cbrowser

#start function
# cd 
# func start

#Add Cosmos nuget package
#dotnet add package Microsoft.Azure.Cosmos --version 3.17.1

# add reference
#dotnet add app/app.csproj reference lib/lib.csproj
#dotnet add FunctionProj/FunctionProj.csproj reference Shared/Shared.csproj

# Add function Extentions
# dotnet add package Microsoft.Azure.Functions.Extensions --version 1.1.0

#Create service principle
# az ad sp create-for-rbac -n="SlotsAppDevOps" --role="Contributor" --scopes="/subscriptions/f800f678-35f3-4453-9d5f-1ce0831dada0"f-1ce0831dada0"