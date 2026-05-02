<#
.SYNOPSIS
Exportar información de todos los stacks a un archivo.

.PARAMETER OutputFile
Archivo de salida (default: stack-outputs.json).

.PARAMETER Region
Región AWS (default: eu-south-2).

.PARAMETER Format
Formato: json, csv, txt (default: json).

.EXAMPLE
.\export-stack-outputs.ps1 -OutputFile "despliegue.json"
#>

param(
    [string]$OutputFile = "stack-outputs.json",
    [string]$Region = "eu-south-2",
    [ValidateSet("json", "csv", "txt")]
    [string]$Format = "json"
)

$students = @("A", "B", "C", "D", "E")
$profiles = @{ "A" = "AlejandroA"; "B" = "NicolasB"; "C" = "MarioC"; "D" = "GonzaloD"; "E" = "JesusE" }
$stackNames = @{ "A" = "dt-a-ad-client"; "B" = "dt-b-lb-db"; "C" = "dt-c-web-u1"; "D" = "dt-d-web-u2"; "E" = "dt-e-web-u3" }

$allData = @()

foreach ($student in $students) {
    $profile = $profiles[$student]
    $stackName = $stackNames[$student]
    
    Write-Host "Exportando $stackName..." -ForegroundColor Cyan
    
    try {
        $stackInfo = aws cloudformation describe-stacks `
            --profile $profile `
            --region $Region `
            --stack-name $stackName `
            --output json | ConvertFrom-Json
        
        $allData += @{
            Student = $student
            StackName = $stackName
            Status = $stackInfo.Stacks[0].StackStatus
            CreationTime = $stackInfo.Stacks[0].CreationTime
            Outputs = $stackInfo.Stacks[0].Outputs
        }
    } catch {
        Write-Host "Error exportando $stackName: $_" -ForegroundColor Red
    }
}

# Guardar según formato
switch ($Format) {
    "json" {
        $allData | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
    }
    "csv" {
        $csvData = @()
        foreach ($item in $allData) {
            foreach ($output in $item.Outputs) {
                $csvData += @{
                    Student = $item.Student
                    StackName = $item.StackName
                    Status = $item.Status
                    OutputKey = $output.OutputKey
                    OutputValue = $output.OutputValue
                }
            }
        }
        $csvData | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
    }
    "txt" {
        $content = ""
        foreach ($item in $allData) {
            $content += "=== $($item.Student) - $($item.StackName) ===" + "`n"
            $content += "Status: $($item.Status)" + "`n"
            $content += "Created: $($item.CreationTime)" + "`n"
            $content += "Outputs:`n"
            foreach ($output in $item.Outputs) {
                $content += "  $($output.OutputKey) = $($output.OutputValue)" + "`n"
            }
            $content += "`n"
        }
        $content | Out-File -FilePath $OutputFile -Encoding UTF8
    }
}

Write-Host "Exportado: $OutputFile" -ForegroundColor Green
