param(
  [string]$Region = "eu-south-2"
)

$ErrorActionPreference = "Stop"

$items = @(
  @{ Profile = "AlejandroA"; Stack = "dt-a-ad-client" },
  @{ Profile = "NicolasB";   Stack = "dt-b-lb-db" },
  @{ Profile = "MarioC";     Stack = "dt-c-web-u1" },
  @{ Profile = "GonzaloD";   Stack = "dt-d-web-u2" },
  @{ Profile = "JesusE";     Stack = "dt-e-web-u3" }
)

foreach ($i in $items) {
  Write-Host "`n=== $($i.Stack) [$($i.Profile)] ==="
  aws cloudformation describe-stacks `
    --profile $i.Profile `
    --region $Region `
    --stack-name $i.Stack `
    --query "Stacks[0].Outputs[].[OutputKey,OutputValue]" `
    --output table

  if ($LASTEXITCODE -ne 0) {
    throw "Failed to export outputs for $($i.Stack)"
  }
}

Write-Host "\nAll outputs exported."
