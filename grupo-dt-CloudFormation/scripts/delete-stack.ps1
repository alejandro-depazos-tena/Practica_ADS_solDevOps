<#
.SYNOPSIS
Eliminar un stack CloudFormation.

.PARAMETER Student
Alumno: A, B, C, D o E (obligatorio).

.PARAMETER Region
Región AWS (default: eu-south-2).

.PARAMETER Confirm
Pedir confirmación (default: true).

.EXAMPLE
.\delete-stack.ps1 -Student A
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("A", "B", "C", "D", "E")]
    [string]$Student,
    
    [string]$Region = "eu-south-2",
    
    [bool]$Confirm = $true
)

$profiles = @{ "A" = "AlejandroA"; "B" = "NicolasB"; "C" = "MarioC"; "D" = "GonzaloD"; "E" = "JesusE" }
$stackNames = @{ "A" = "dt-a-ad-client"; "B" = "dt-b-lb-db"; "C" = "dt-c-web-u1"; "D" = "dt-d-web-u2"; "E" = "dt-e-web-u3" }

$profile = $profiles[$Student]
$stackName = $stackNames[$Student]

Write-Host "`n=== Eliminar Stack ===" -ForegroundColor Red
Write-Host "Alumno: $Student"
Write-Host "Stack: $stackName"
Write-Host "Región: $Region"

if ($Confirm) {
    $response = Read-Host "`n¿Estás seguro? (s/n)"
    if ($response -ne "s") {
        Write-Host "Cancelado." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "`nEliminando..." -ForegroundColor Yellow
aws cloudformation delete-stack `
    --profile $profile `
    --region $Region `
    --stack-name $stackName

Write-Host "Stack $stackName eliminado." -ForegroundColor Green
