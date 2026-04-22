param(
  [string]$Region = "eu-south-2",
  [Parameter(Mandatory = $true)][string]$AdminCidr,
  [Parameter(Mandatory = $true)][string]$BudgetEmail,
  [Parameter(Mandatory = $true)][string]$KeyPairA,
  [Parameter(Mandatory = $true)][string]$KeyPairB,
  [Parameter(Mandatory = $true)][string]$KeyPairC,
  [Parameter(Mandatory = $true)][string]$KeyPairD,
  [Parameter(Mandatory = $true)][string]$KeyPairE
)

$ErrorActionPreference = "Stop"

function Run-Deploy {
  param(
    [string]$Profile,
    [string]$StackName,
    [string]$TemplateFile,
    [string[]]$Overrides
  )

  Write-Host "Deploying $StackName with profile $Profile..."
  aws cloudformation deploy `
    --profile $Profile `
    --region $Region `
    --stack-name $StackName `
    --template-file $TemplateFile `
    --capabilities CAPABILITY_NAMED_IAM `
    --parameter-overrides @Overrides

  if ($LASTEXITCODE -ne 0) {
    throw "Failed deploying $StackName ($Profile)"
  }
}

Run-Deploy -Profile "AlejandroA" -StackName "dt-a-ad-client" -TemplateFile "cloudformation/strict-5/stack-A-ad-client.yaml" -Overrides @(
  "KeyPairName=$KeyPairA",
  "AdminCidr=$AdminCidr",
  "BudgetEmail=$BudgetEmail"
)

Run-Deploy -Profile "NicolasB" -StackName "dt-b-lb-db" -TemplateFile "cloudformation/strict-5/stack-B-lb-db.yaml" -Overrides @(
  "KeyPairName=$KeyPairB",
  "AdminCidr=$AdminCidr",
  "BudgetEmail=$BudgetEmail"
)

Run-Deploy -Profile "MarioC" -StackName "dt-c-web-u1" -TemplateFile "cloudformation/strict-5/stack-C-web-upstream1.yaml" -Overrides @(
  "KeyPairName=$KeyPairC",
  "AdminCidr=$AdminCidr",
  "LbVpcCidr=10.20.0.0/16",
  "BudgetEmail=$BudgetEmail"
)

Run-Deploy -Profile "GonzaloD" -StackName "dt-d-web-u2" -TemplateFile "cloudformation/strict-5/stack-D-web-upstream2.yaml" -Overrides @(
  "KeyPairName=$KeyPairD",
  "AdminCidr=$AdminCidr",
  "LbVpcCidr=10.20.0.0/16",
  "BudgetEmail=$BudgetEmail"
)

Run-Deploy -Profile "JesusE" -StackName "dt-e-web-u3" -TemplateFile "cloudformation/strict-5/stack-E-web-upstream3.yaml" -Overrides @(
  "KeyPairName=$KeyPairE",
  "AdminCidr=$AdminCidr",
  "LbVpcCidr=10.20.0.0/16",
  "BudgetEmail=$BudgetEmail"
)

Write-Host "All strict-5 CloudFormation stacks deployed successfully."
