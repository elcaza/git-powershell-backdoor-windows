"Ejecutando script"
$payload = "hello_world.ps1"

# calc.exe
powershell -ExecutionPolicy Bypass payloads\$payload
"Listo"