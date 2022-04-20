$resourceGroup="teamResources"
$clusterName="openhackPrivateRBACCluster"
$vnetName="vnet"
$subnetName="oh-subnet"
$acrName="registryznq7406"
$adAdminGroupId="37e8a53c-8ed3-44db-b08b-090d37d567de"
$adApiGroupId="3cbd226d-08b2-40c8-be76-f84217af2341"
$adWebGroupId="646ab333-0ac4-41be-8a3c-1c0f291be18b"

# Get AKS Id
$aksJson = az aks show --resource-group $resourceGroup --name $clusterName | ConvertFrom-Json

# Get ACR Id
$acrJson = az acr show -g $resourceGroup -n $acrName | ConvertFrom-Json

# Get subnet Id
$vnetJson = az network vnet subnet show -g $resourceGroup --vnet-name $vnetName -n $subnetName | ConvertFrom-Json

# Create cluster in VNet Address space (Run once)
# az aks create -g $resourceGroup -n $clusterName --node-count 3 --network-plugin azure --vnet-subnet-id $vnetJson.id --attach-acr $acrJson.id --enable-aad --aad-admin-group-object-ids $adAdminGroupId --enable-azure-rbac

# Assign AD Group Permission
az role assignment create --assignee $adApiGroupId --role "Azure Kubernetes Service Cluster User Role" --scope $aksJson.id
az role assignment create --assignee $adWebGroupId --role "Azure Kubernetes Service Cluster User Role" --scope $aksJson.id

# Get Credentials
az aks get-credentials --resource-group $resourceGroup --name $clusterName --admin

# Quick check on cluster
kubectl get nodes

# Create namespace
kubectl create ns api
kubectl create ns web

# Deploy Roles
kubectl apply -f kubernetes/roles/admin.role.yaml
kubectl apply -f kubernetes/roles/api.role.yaml
kubectl apply -f kubernetes/roles/web.role.yaml

# Create secrets
kubectl create secret generic openhacksecret --from-literal=sql_user='sqladminzNq7406' --from-literal=sql_password='Rs^Nh66#&^5g' --from-literal=sql_server='sqlserverznq7406.database.windows.net' --from-literal=sql_dbname='mydrivingDB' --namespace=api

# Rollout Backend deployments
kubectl apply -f kubernetes/deployments/api.deploy.yaml
kubectl apply -f kubernetes/services/api.service.yaml

# Rollout Frontend Deployments
kubectl apply -f kubernetes/deployments/web.deploy.yaml
kubectl apply -f kubernetes/services/web.service.yaml


