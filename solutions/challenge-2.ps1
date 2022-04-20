$resourceGroup="teamResources"
$clusterName="openhackCluster"
$ACRId="/subscriptions/22c093fe-6552-48dd-bbad-9110d7c4db32/resourceGroups/teamResources/providers/Microsoft.ContainerRegistry/registries/registryznq7406"
$publicIPName="openhackPublicIP"

# Create a AKS cluster (Run it once)
# az aks create --resource-group $resourceGroup --name $clusterName --node-count 1 --enable-addons monitoring http_application_routing --generate-ssh-keys
# az aks update -n $clusterName -g $resourceGroup --attach-acr $ACRId
# az aks addon enable -a http_application_routing -n $clusterName -g $resourceGroup

# Create Public IP
# $resourceGroupValue = az aks show --resource-group $resourceGroup --name $clusterName --query nodeResourceGroup -o tsv
# $publicIP = az network public-ip create --resource-group $resourceGroupValue --name $publicIPName --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv
# $publicIP = "20.187.109.219"

# Get DNS for cluster
# $dnsUrl = az aks show -g $resourceGroup -n $clusterName --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table
# $dnsUrl = "b2d0aa41181e47a1b55f.eastasia.aksapp.io"

# Setup CLI
az aks get-credentials --resource-group $resourceGroup --name $clusterName

# Quick check on cluster
kubectl get nodes

# Create namespaces
kubectl create ns oh-backend
kubectl create ns oh-frontend

# Create secrets
kubectl edit secret generic openhacksecret --from-literal=sql_user='sqladminzNq7406' --from-literal=sql_password='Rs^Nh66#&^5g' --from-literal=sql_server='sqlserverznq7406.database.windows.net' --from-literal=sql_dbname='mydrivingDB' --namespace=oh-backend


# Rollout Backend deployments
kubectl apply -f kubernetes/deployments/oh-backend.deploy.yaml
kubectl apply -f kubernetes/services/oh-backend.service.yaml

# Rollout Frontend Deployments
kubectl apply -f kubernetes/deployments/oh-frontend.deploy.yaml
kubectl apply -f kubernetes/services/oh-frontend.service.yaml