"Ejecutando script"
$payload = "show_text.ps1"

git pull origin master
powershell -ExecutionPolicy Bypass payloads\$payload
"Listo"