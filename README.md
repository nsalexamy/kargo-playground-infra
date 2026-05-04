# Kargo Playground Infra

## Delete 
```bash
# with the provider-grafana up and running, it keeps re-creating the CRDs
kubectl delete provider provider-grafana

kubectl get crd | grep -E 'grafana.*\.crossplane\.io' | awk '{print $1}' | xargs kubectl delete crd 
```