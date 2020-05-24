"Ejecutando script"
$payload = "hello_world.ps1"

git pull origin master
powershell -ExecutionPolicy Bypass payloads\$payload
"Listo"