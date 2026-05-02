<#
.SYNOPSIS
Obtener información de un stack CloudFormation.

.PARAMETER Student
Alumno: A, B, C, D o E (obligatorio).

.PARAMETER Region
Región AWS (default: eu-south-2).

.PARAMETER ShowOutputs
Mostrar outputs del stack (default: true).

.EXAMPLE
.\get-stack-info.ps1 -Student A
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("A", "B", "C", "D", "E")]
    [string]$Student,
    
    [string]$Region = "eu-south-2",
    
    [bool]$ShowOutputs = $true
)

$profiles = @{ "A" = "AlejandroA"; "B" = "NicolasB"; "C" = "MarioC"; "D" = "GonzaloD"; "E" = "JesusE" }
$stackNames = @{ "A" = "dt-a-ad-client"; "B" = "dt-b-lb-db"; "C" = "dt-c-web-u1"; "D" = "dt-d-web-u2"; "E" = "dt-e-web-u3" }

$profile = $profiles[$Student]
$stackName = $stackNames[$Student]

Write-Host "`n=== Stack Info: $stackName ===" -ForegroundColor Cyan

# Stack info
aws cloudformation describe-stacks `
    --profile $profile `
    --region $Region `
    --stack-name $stackName `
    --query 'Stacks[0].[StackName,StackStatus,CreationTime,LastUpdatedTime]' `
    --output table

# Resources
Write-Host "`n=== Resources ===" -ForegroundColor Yellow
aws cloudformation list-stack-resources `
    --profile $profile `
    --region $Region `
    --stack-name $stackName `
    --query 'StackResourceSummaries[*].[ResourceType,LogicalResourceId,ResourceStatus]' `
    --output table

# Outputs
if ($ShowOutputs) {
    Write-Host "`n=== Outputs ===" -ForegroundColor Green
    aws cloudformation describe-stacks `
        --profile $profile `
        --region $Region `
        --stack-name $stackName `
        --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' `
        --output table
}

Write-Host "`n"
