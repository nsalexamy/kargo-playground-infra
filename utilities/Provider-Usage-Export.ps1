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
kubectl get crds -o json | ConvertFrom-Json | Select-Object -ExpandProperty items | ForEach-Object {
    #$crd = $_
    #Write-Output "Processing CRD: $($crd.metadata)"

    ForEach-Object {
        $crd = $_

        # Check if the CRD name contains the provider suffix
        if ($crd.metadata.name -notlike "*$provider_suffix*") {
            return
        }

        Write-Output "Processing CRD: $($crd.metadata.name)"
        # if the CRD has items with providerConfigRef that matches the provider suffix, add it to the results
        $crds = kubectl get $($crd.metadata.name) --all-namespaces -o json | ConvertFrom-Json
        if ($crds.items.length -gt 0) {
            $results += $crd.metadata.name
        }
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