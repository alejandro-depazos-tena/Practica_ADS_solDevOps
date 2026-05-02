# Archivo de configuración ejemplo para despliegue CloudFormation
# Copia este archivo como 'config.ps1' en la carpeta scripts/ y personaliza

# ============================================================================
# CONFIGURACIÓN GENERAL
# ============================================================================

# Región AWS
$Region = "eu-south-2"

# Email para alertas de presupuesto
$BudgetEmail = "admin@empresa.com"

# Segundos de espera entre despliegues secuenciales
$WaitBetweenDeploys = 30

# ============================================================================
# CONFIGURACIÓN DE PERFILES Y KEY PAIRS
# ============================================================================

# Mapeo de alumnos a perfiles AWS
$AWSProfiles = @{
    "A" = "AlejandroA"
    "B" = "NicolasB"
    "C" = "MarioC"
    "D" = "GonzaloD"
    "E" = "JesusE"
}

# Mapeo de alumnos a nombres de key pair
$KeyPairNames = @{
    "A" = "dt-a-key"
    "B" = "dt-b-key"
    "C" = "dt-c-key"
    "D" = "dt-d-key"
    "E" = "dt-e-key"
}

# Mapeo de alumnos a nombres de stack
$StackNames = @{
    "A" = "dt-a-ad-client"
    "B" = "dt-b-lb-db"
    "C" = "dt-c-web-u1"
    "D" = "dt-d-web-u2"
    "E" = "dt-e-web-u3"
}

# ============================================================================
# IP ADMINISTRATIVA (Reemplaza con tu IP pública)
# ============================================================================

# Obtener automáticamente
$AdminIpAuto = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
$AdminCidr = "$AdminIpAuto/32"

# O ingresa manualmente (si lo prefieres)
# $AdminCidr = "203.0.113.42/32"

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

function Get-Configuration {
    param([string]$Student)
    
    return @{
        Profile     = $AWSProfiles[$Student]
        KeyPair     = $KeyPairNames[$Student]
        StackName   = $StackNames[$Student]
        AdminCidr   = $AdminCidr
        BudgetEmail = $BudgetEmail
        Region      = $Region
    }
}

function Show-Configuration {
    Write-Host "`n=== CONFIGURACIÓN ===" -ForegroundColor Cyan
    Write-Host "Región: $Region" -ForegroundColor Green
    Write-Host "Tu IP: $AdminCidr" -ForegroundColor Green
    Write-Host "Email: $BudgetEmail" -ForegroundColor Green
    Write-Host "Espera entre deploys: $WaitBetweenDeploys segundos" -ForegroundColor Green
    Write-Host "`n=== ALUMNOS ===" -ForegroundColor Cyan
    
    foreach ($student in @("A", "B", "C", "D", "E")) {
        $config = Get-Configuration $student
        Write-Host "Alumno $student → Perfil: $($config.Profile), Stack: $($config.StackName)" -ForegroundColor Yellow
    }
    Write-Host "`n"
}

# ============================================================================
# EJEMPLO DE USO EN LOS SCRIPTS
# ============================================================================

<#
# En deploy-all.ps1, podría usarse así:

. .\config.ps1

foreach ($student in @("A", "B", "C", "D", "E")) {
    $config = Get-Configuration $student
    
    aws cloudformation deploy `
        --profile $($config.Profile) `
        --region $($config.Region) `
        --stack-name $($config.StackName) `
        --template-file "..\cloudformation\strict-5\stack-$student-*.yaml" `
        --capabilities CAPABILITY_NAMED_IAM `
        --parameter-overrides `
            KeyPairName=$($config.KeyPair) `
            AdminCidr=$($config.AdminCidr) `
            BudgetEmail=$($config.BudgetEmail)
}

# O simplemente
Show-Configuration
#>

# ============================================================================
# USO
# ============================================================================

# 1. Personaliza este archivo con tus valores
# 2. Guárdalo como 'config.ps1' en la carpeta scripts/
# 3. En tus scripts, importa:
#    . .\config.ps1
# 4. Accede a variables:
#    $AdminCidr
#    $BudgetEmail
#    Get-Configuration "A"
