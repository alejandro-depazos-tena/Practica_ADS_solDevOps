param(
  [string]$BucketName = "",
  [string]$Destination = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($BucketName) -or [string]::IsNullOrWhiteSpace($Destination)) {
  throw "Debes indicar BucketName y Destination."
}

New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$target = Join-Path $Destination "s3-backup-$timestamp"

aws s3 sync "s3://$BucketName" $target --delete
Write-Host "Copia S3 completada en $target"
