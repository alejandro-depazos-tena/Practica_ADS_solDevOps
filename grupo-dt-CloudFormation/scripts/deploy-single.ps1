<#
.SYNOPSIS
Despliegue individual de un stack CloudFormation.

.PARAMETER Student
Alumno: A, B, C, D o E (obligatorio).

.PARAMETER AdminCidr
CIDR administrativo para RDP/SSH (obligatorio).

.PARAMETER BudgetEmail
Email para alertas de presupuesto (obligatorio).

.PARAMETER Region
Región AWS (default: eu-south-2).

.PARAMETER KeyPairName
Nombre custom de key pair (si no usa patrón estándar).

.EXAMPLE
.\deploy-single.ps1 -Student A -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("A", "B", "C", "D", "E")]
    [string]$Student,
    
    [Parameter(Mandatory=$true)]
    [string]$AdminCidr,
    
    [Parameter(Mandatory=$true)]
    [string]$BudgetEmail,
    
    [string]$Region = "eu-south-2",
    
    [string]$KeyPairName = ""
)

# Configuración
$profiles = @{
    "A" = "AlejandroA"
    "B" = "NicolasB"
    "C" = "MarioC"
    "D" = "GonzaloD"
    "E" = "JesusE"
}
$defaultKeyPairs = @{
    "A" = "dt-a-key"
    "B" = "dt-b-key"
    "C" = "dt-c-key"
    "D" = "dt-d-key"
    "E" = "dt-e-key"
}
$stackNames = @{
    "A" = "dt-a-ad-client"
    "B" = "dt-b-lb-db"
    "C" = "dt-c-web-u1"
    "D" = "dt-d-web-u2"
    "E" = "dt-e-web-u3"
}
$stackTemplates = @{
    "A" = "stack-A-ad-client.yaml"
    "B" = "stack-B-lb-db.yaml"
    "C" = "stack-C-web-upstream1.yaml"
    "D" = "stack-D-web-upstream2.yaml"
    "E" = "stack-E-web-upstream3.yaml"
}

$profile = $profiles[$Student]
$stackName = $stackNames[$Student]
$keyPair = if ([string]::IsNullOrEmpty($KeyPairName)) { $defaultKeyPairs[$Student] } else { $KeyPairName }
$template = $stackTemplates[$Student]
$templatePath = "..\cloudformation\strict-5\$template"

# Colores
$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Cyan

function Write-Info { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor $Blue }
function Write-Success { param([string]$M) Write-Host "[SUCCESS] $M" -ForegroundColor $Green }
function Write-Error2 { param([string]$M) Write-Host "[ERROR] $M" -ForegroundColor $Red }

# Validar archivo
if (-not (Test-Path $templatePath)) {
    Write-Error2 "Template no encontrado: $templatePath"
    exit 1
}

Write-Info "====== Despliegue Alumno $Student ======"
Write-Info "Perfil: $profile"
Write-Info "Stack: $stackName"
Write-Info "Template: $templatePath"
Write-Info "KeyPair: $keyPair"
Write-Info "Región: $Region"

try {
    aws cloudformation deploy `
        --profile $profile `
        --region $Region `
        --stack-name $stackName `
        --template-file $templatePath `
        --capabilities CAPABILITY_NAMED_IAM `
        --parameter-overrides `
            KeyPairName=$keyPair `
            AdminCidr=$AdminCidr `
            BudgetEmail=$BudgetEmail `
            EnableBudget=true
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Stack $stackName desplegado exitosamente"
        Write-Info "Ejecuta: .\get-stack-info.ps1 -Student $Student"
    } else {
        Write-Error2 "Error en el despliegue"
        exit 1
    }
} catch {
    Write-Error2 "Excepción: $_"
    exit 1
}
