$resourceGroup="teamResources"
$clusterName="openhackPrivateRBACCluster"
$keyVaultName="openhack4KeyVault"
$identityName="ohIdentity"
$podIdentityName="oh-pod-identity"
$acrName="registryznq7406"

# Enable Addon AKVS Provider (Run Once)
# az aks enable-addons --addons azure-keyvault-secrets-provider -n $clusterName  -g $resourceGroup

# Create Azure KeyVault
# az keyvault create -n $keyVaultName -g $resourceGroup

# Add Secrets to Azure KeyVault
# az keyvault secret set --vault-name $keyVaultName --name "sql-user" --value 'sqladminzNq7406'
# # !!!!!Something weird happens with value has '^' add it manually in the portal
# az keyvault secret set --vault-name $keyVaultName --name "sql-password" --value 'Rs^Nh66#&^5g'
# az keyvault secret set --vault-name $keyVaultName --name "sql-server" --value 'sqlserverznq7406.database.windows.net'
# az keyvault secret set --vault-name $keyVaultName --name "sql-dbname" --value 'mydrivingDB'

# Enable Managed Identity for AKS
# az aks update -g $resourceGroup -n $clusterName --enable-managed-identity
# az identity create -g $resourceGroup -n $identityName

# Use a user assigned managed identity
# $akvIndentityClientId = az aks show -g $resourceGroup -n $clusterName --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId
$akvIndentityClientId="910b2490-e0e2-48ed-af9d-4a8a28f7a49e"
# az keyvault set-policy -n $keyVaultName --key-permissions get --spn $akvIndentityClientId
# az keyvault set-policy -n $keyVaultName --secret-permissions get --spn $akvIndentityClientId
# az keyvault set-policy -n $keyVaultName --certificate-permissions get --spn $akvIndentityClientId

# Delete Namespace secret
# kubectl delete secret openhacksecret --namespace api

# Delete old API deployment
# kubectl delete deploy oh-poi --namespace api
# kubectl delete deploy oh-trips --namespace api
# kubectl delete deploy oh-user-java --namespace api
# kubectl delete deploy oh-userprofile --namespace api

# Deploy Secret Provider Class
# kubectl apply -f kubernetes/secretsproviderclass.yaml

# Deploy New API deployment
# kubectl apply -f kubernetes/deployments/api.deploy.yaml

# Create Ingress Controller
$ingressNamespace="ingress-ns"
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update

# helm install ingress-nginx ingress-nginx/ingress-nginx --create-namespace --namespace $ingressNamespace

# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# $acrUrl = az acr show -g $resourceGroup -n $acrName --query loginServer
$acrUrl = "registryznq7406.azurecr.io"
$sourceRegistry="k8s.gcr.io"
$controllerImage="ingress-nginx/controller"
$controllerTag="v1.0.4"
$patchImage="ingress-nginx/kube-webhook-certgen"
$patchTag="v1.1.1"
$defaultbackendImage="defaultbackend-amd64"
$defaultbackendTag="1.5"
$publicIPName="openhackPublicIP"

# az network public-ip create --resource-group $resourceGroup --name $publicIPName --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv
$publicIP="20.187.121.97"

# helm install ingress-nginx ingress-nginx/ingress-nginx --create-namespace --namespace $ingressNamespace

# az acr import --name $acrName --source "$sourceRegistry/$controllerImage `:$controllerTag" --image "$controllerImage`:$controllerTag"
# az acr import --name $acrName --source "$sourceRegistry/$patchImage`:$patchTag" --image "$patchImage`:$patchTag"
# az acr import --name $acrName --source "$sourceRegistry/$defaultbackendImage`:$defaultbackendTag" --image "$defaultbackendImage`:$defaultbackendTag"

helm install ingress-nginx ingress-nginx/ingress-nginx `
    --namespace $ingressNamespace --create-namespace `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."kubernetes\.io/os"=linux `
    --set controller.image.registry=$acrUrL `
    --set controller.image.image=$controllerImage `
    --set controller.image.tag=$controllerTag `
    --set controller.image.digest="" `
    --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux `
    --set controller.admissionWebhooks.patch.image.registry=$acrUrl `
    --set controller.admissionWebhooks.patch.image.image=$patchImage `
    --set controller.admissionWebhooks.patch.image.tag=$patchTag `
    --set controller.admissionWebhooks.patch.image.digest="" `
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux `
    --set defaultBackend.image.registry=$acrUrl `
    --set defaultBackend.image.image=$defaultBackendImage `
    --set defaultBackend.image.tag=$defaultBackendTag `
    --set defaultBackend.image.digest="" `

# kubectl -n $ingressNamespace get services

# az aks enable-addons --resource-group $resourceGroup --name $clusterName --addons http_application_routing
# $routingZone=az aks show --resource-group $resourceGroup --name $clusterName --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName
$routingZone="d97d998275e1497d9670.eastasia.aksapp.io"

# Deploy Ingress Routes
kubectl apply -f kubernetes/ingress/api.ingress.yaml
kubectl apply -f kubernetes/ingress/web.ingress.yaml