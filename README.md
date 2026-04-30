# Kargo Playground Infra

[source,bash]
----
kubectl get crd | grep -E 'grafana.*\.crossplane\.io' | awk '{print $1}' | xargs kubectl delete crd 
----