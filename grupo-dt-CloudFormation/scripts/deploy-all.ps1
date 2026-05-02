<#
.SYNOPSIS
Despliegue completo de todos los stacks CloudFormation (5 cuentas).

.DESCRIPTION
Despliega todos los stacks de las 5 cuentas (A, B, C, D, E) en secuencia,
esperando a que cada uno se complete correctamente.

.PARAMETER AdminCidr
CIDR administrativo para RDP/SSH (ejemplo: 203.0.113.42/32).

.PARAMETER BudgetEmail
Email para recibir alertas de presupuesto.

.PARAMETER Region
Región AWS donde desplegar (default: eu-south-2).

.PARAMETER WaitBetweenDeploys
Segundos de espera entre despliegues (default: 30).

.EXAMPLE
.\deploy-all.ps1 -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$AdminCidr,
    
    [Parameter(Mandatory=$true)]
    [string]$BudgetEmail,
    
    [string]$Region = "eu-south-2",
    
    [int]$WaitBetweenDeploys = 30
)

# Configuración
$students = @("A", "B", "C", "D", "E")
$profiles = @{
    "A" = "AlejandroA"
    "B" = "NicolasB"
    "C" = "MarioC"
    "D" = "GonzaloD"
    "E" = "JesusE"
}
$keyPairs = @{
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

# Colores
$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Cyan

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Error2 {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

# Validar AWS CLI
Write-Info "Validando AWS CLI..."
try {
    $awsVersion = aws --version
    Write-Success "AWS CLI: $awsVersion"
} catch {
    Write-Error2 "AWS CLI no está instalado o no está en PATH"
    exit 1
}

# Validar perfiles
Write-Info "Validando perfiles AWS..."
foreach ($student in $students) {
    $profile = $profiles[$student]
    try {
        $result = aws sts get-caller-identity --profile $profile 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Perfil $profile: OK"
        } else {
            Write-Error2 "Perfil $profile: FALLÓ"
            exit 1
        }
    } catch {
        Write-Error2 "Error validando $profile: $_"
        exit 1
    }
}

# Despliegue
Write-Info "====== INICIO DE DESPLIEGUE COMPLETO ======"
$startTime = Get-Date

foreach ($student in $students) {
    $profile = $profiles[$student]
    $stackName = $stackNames[$student]
    $keyPair = $keyPairs[$student]
    $templateFile = "..\cloudformation\strict-5\stack-$($student)-*.yaml"
    
    # Expandir wildcard (encontrar el archivo correcto)
    $templates = Get-ChildItem -Path $templateFile -ErrorAction SilentlyContinue
    if ($templates.Count -eq 0) {
        Write-Error2 "Template no encontrado para Alumno $student"
        continue
    }
    $templatePath = $templates[0].FullName
    
    Write-Info "====== Alumno $student - Stack $stackName ======"
    Write-Info "Perfil: $profile"
    Write-Info "Template: $templatePath"
    Write-Info "KeyPair: $keyPair"
    
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
        } else {
            Write-Error2 "Error desplegando $stackName"
            continue
        }
    } catch {
        Write-Error2 "Excepción desplegando $stackName: $_"
        continue
    }
    
    if ($student -ne $students[-1]) {
        Write-Info "Esperando $WaitBetweenDeploys segundos antes del siguiente despliegue..."
        Start-Sleep -Seconds $WaitBetweenDeploys
    }
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Success "====== DESPLIEGUE COMPLETO FINALIZADO ======"
Write-Success "Tiempo total: $($duration.TotalMinutes.ToString('F2')) minutos"
Write-Info "Verifica los stacks en la consola de CloudFormation"
