# Pass pkg_suffix as an argument to the script, e.g.:
# .\Provider-Usage-Export.ps1 -provider_suffix "grafana.crossplane.io"
param (
    [string]$provider_suffix
)
Write-Output "Exporting usage for provider suffix: $provider_suffix"

# Error handling for missing argument
if (-not $provider_suffix) {
    Write-Host "Please provide a provider suffix as an argument, e.g. -provider_suffix 'grafana.crossplane.io'."
    exit
}

$results = @()

# search all CRDs with the specified provider suffix and extract usage information
kubectl get crds -o name | Where-Object { $_ -like "*$provider_suffix*" } | ForEach-Object {
    #Write-Output "Processing CRD: $_"

    # trim until '/' to get the CRD name
    $crdName = $_.Split('/')[1]
    Write-Output "CRD name: $crdName"
    $crds = kubectl get $($crdName) --all-namespaces -o json | ConvertFrom-Json
    if ($crds.items.length -gt 0) {
        $results += $crdName
    }

} 

# Output

if ( $results.Count -eq 0 ) {
    Write-Output "No results found for provider suffix '$provider_suffix'."
    Write-Output "Empty result will be saved to provider_usage_$provider_suffix.json."
    $results | ConvertTo-Json -Depth 100 | Out-File -FilePath "provider_usage_$provider_suffix.json" -Encoding utf8
} else {
    $results | ConvertTo-Json -Depth 100 | Out-File -FilePath "provider_usage_$provider_suffix.json" -Encoding utf8
}