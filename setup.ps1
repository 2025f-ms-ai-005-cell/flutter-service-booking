$ErrorActionPreference = 'Stop'
$destination = Join-Path $PSScriptRoot 'app'
if (Test-Path -LiteralPath $destination) { throw 'app already exists; use it or choose a fresh folder. Nothing overwritten.' }
flutter create --platforms=android,web --project-name service_booking_demo $destination
if ($LASTEXITCODE -ne 0) { throw 'Flutter project creation failed.' }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'pubspec.yaml') -Destination (Join-Path $destination 'pubspec.yaml')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'booking_app.dart') -Destination (Join-Path $destination 'lib/main.dart')
Remove-Item -LiteralPath (Join-Path $destination 'test/widget_test.dart')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'booking_test.dart') -Destination (Join-Path $destination 'test/booking_test.dart')
Push-Location $destination
try { flutter pub get; if ($LASTEXITCODE -ne 0) { throw 'Dependency setup failed.' } } finally { Pop-Location }
