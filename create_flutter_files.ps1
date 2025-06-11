# Get the current directory (should be the Flutter project root)
$projectRoot = Get-Location

Write-Host "Creating Flutter project structure in: $projectRoot"

# --- 1. Create Core Directories ---
$baseDirs = @(
    "lib/config",
    "lib/services",
    "lib/models",
    "lib/providers",
    "lib/screens/auth",
    "lib/screens/dashboards"
)

foreach ($dir in $baseDirs) {
    $fullPath = Join-Path $projectRoot $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath | Out-Null
        Write-Host "Created directory: $dir"
    } else {
        Write-Host "Directory already exists: $dir"
    }
}

# --- 2. Create Config Files ---
$configFiles = @(
    "lib/config/env.dart",
    "lib/config/config.dart"
)

foreach ($file in $configFiles) {
    $filePath = Join-Path $projectRoot $file
    if (-not (Test-Path $filePath)) {
        Set-Content -Path $filePath -Value "" | Out-Null
        Write-Host "Created file: $file"
    } else {
        Write-Host "File already exists: $file"
    }
}

# --- 3. Create Service Files ---
$serviceFiles = @(
    "lib/services/api_service.dart"
)

foreach ($file in $serviceFiles) {
    $filePath = Join-Path $projectRoot $file
    if (-not (Test-Path $filePath)) {
        Set-Content -Path $filePath -Value "" | Out-Null
        Write-Host "Created file: $file"
    } else {
        Write-Host "File already exists: $file"
    }
}

# --- 4. Create Model Files ---
$modelFiles = @(
    "lib/models/api_response.dart",
    "lib/models/pagination.dart",
    "lib/models/specialization.dart",
    "lib/models/doctor_profile.dart",
    "lib/models/user.dart",
    "lib/models/payment.dart",
    "lib/models/appointment.dart",
    "lib/models/doctor_availability.dart",
    "lib/models/message.dart",
    "lib/models/prescription.dart",
    "lib/models/consultation.dart",
    "lib/models/faq.dart",
    "lib/models/public_question.dart",
    "lib/models/public_question_answer.dart",
    "lib/models/blog_post.dart",
    "lib/models/blog_comment.dart"
)

foreach ($file in $modelFiles) {
    $filePath = Join-Path $projectRoot $file
    if (-not (Test-Path $filePath)) {
        Set-Content -Path $filePath -Value "" | Out-Null
        Write-Host "Created file: $file"
    } else {
        Write-Host "File already exists: $file"
    }
}

# --- 5. Create Provider Files ---
$providerFiles = @(
    "lib/providers/auth_provider.dart",
    "lib/providers/general_data_provider.dart",
    "lib/providers/patient_provider.dart",
    "lib/providers/doctor_provider.dart"
)

foreach ($file in $providerFiles) {
    $filePath = Join-Path $projectRoot $file
    if (-not (Test-Path $filePath)) {
        Set-Content -Path $filePath -Value "" | Out-Null
        Write-Host "Created file: $file"
    } else {
        Write-Host "File already exists: $file"
    }
}

# --- 6. Create Screen Files ---
$screenFiles = @(
    "lib/screens/loading_screen.dart",
    "lib/screens/dashboard_screen.dart",
    "lib/screens/auth/login_screen.dart",
    "lib/screens/auth/register_screen.dart",
    "lib/screens/dashboards/patient_dashboard_screen.dart",
    "lib/screens/dashboards/doctor_dashboard_screen.dart"
)

foreach ($file in $screenFiles) {
    $filePath = Join-Path $projectRoot $file
    if (-not (Test-Path $filePath)) {
        Set-Content -Path $filePath -Value "" | Out-Null
        Write-Host "Created file: $file"
    } else {
        Write-Host "File already exists: $file"
    }
}

Write-Host "File structure creation complete. Remember to copy and paste the code into the new files."