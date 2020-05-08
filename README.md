# Git Backdoor

Este proyecto muestra la posibilidad de hacer uso de el servicio de github como un backdoor para Windows y Linux.

# Funcionamiento

A través de `installer_system.ext` nosotros instalaremos nuestro backdoor y lo ejecutaremos como una tarea programada.
+ Instala git
+ Clona el repositorio backdoor
+ Programa una tarea para ejecutarse

Con lo anterior nosotros estaremos ejecutando periodicamente nuestro `main.ps1`. Este archivo:
+ Será actualizado antes de ejecutarse mediante un `git pull`
    + Esto le permite ser modificado desde el repositorio base
+ Lanzará nuestros payloads

# Entorno en el que ha sido probado

+ Windows 10
+ Debian 10

# Anexo 1: Ejecución de Scripts de powershell en modo Bypass

Powershell en Windows 10 tiene por defecto una politica de ejecución de scripts. 

Para consultar dicha politica

``` powershell
Get-ExecutionPolicy -list
```

Modos de la politica
+ `Restricted` Opción predefinida en Windows 10. No permite ejecutar scripts, ni archivos de configuración .ps1xml u otros similares, sino solo comandos.
+ `Allsigned` Permite ejecución de scripts y archivos de configuración firmados por un editor de confianza. Esto incluye los escritos en el equipo local. Conlleva el riesgo de ejecutar un script que sea malintencionado, a pesar de haber sido firmado.
+ `RemoteSigned` RemoteSigned: permite ejecutar scripts powershell y archivos de configuración descargados de internet (de cualquier forma). Conlleva cierto riesto, dado que no solicita firmas digitales para scripts diseñados en el equipo local. Para ejecutar scripts descargados de internet (sin firmar) es necesario usar la opción Unblock-File.
+ `Unrestricted` permite ejecutar cualquier script o archivo de configuración, esté firmado o no. Muestra advertencia al usuario.
+ `Bypass` similar al anterior, pero además de no bloquear tampoco alerta de los riesgos. Este modo se suele utilizar en integraciones de Powershell con otras aplicaciones, en las que funciona en una capa inferior, dado que dichas aplicaciones cuentan con un modelo de seguridad propio.
+ `Undefined` no se establece directiva alguna. Esto se traduce normalmente en “Restricted”, suponiendo que en todos los ámbitos se haya dejado sin definir.

Para cambiar la politica de ejecución de los scripts

``` powershell
Set-ExecutionPolicy RemoteSigned
```

Para cambiar la politica de ejecución de los scripts

``` powershell
Set-ExecutionPolicy RemoteSigned -Force
```
+ Este modo forza el cambio

Para ejecutar un script sin en modo Bypass

``` powershell
powershell –ExecutionPolicy Bypass hello_world.ps1
```

# Anexo 2: Scheduled Task en Windows

Las tareas programadas son lo que nos permiten hacer que nuestro backdoor se ejecute de forma periódica. Cabe destacar que Windows y su Scheduled Task no se llevan bien con los espacios en sus nombres de directorios QUE ELLOS MISMOS OCUPAN. Por ejemplo, `C:\Program Files (x86)` y `C:\Program Files`. **#HateWindows** por hacer innecesariamente complicado lo que es simple.

## A) Creación de tareas programadas


### 1) Se crea una acción programada 
Se define qué es lo que nuestra tarea debe realizar

Acción simple

``` powershell
$action = New-ScheduledTaskAction -Execute "notepad.exe"
```
+ Guardamos en la variable `$action` la acción que ejecutará `notepad.exe`

Acción con argumetos

``` powershell
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument -file $program_location + $program_to_execute
```
+ `$action` es la variable que guardará la acción que ejecutará `notepad.exe`
+ `-AsJob` es un parametro que nos permitiría correrlo en segundo plano. Para tareas largas
+ `-Argument` es un parametro que nos permite definir argumentos.


### 2) Se crea un disparador
Aquí definimos qué es lo que activará nuestra tarea programada
``` powershell
$trigger = New-ScheduledTaskTrigger -Once -At 7am -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)
```
+ `$trigger` es nuestra variable que almacenará nuestro disparador
+ `-Once` Ejecuta la tarea solamente una vez. En lugar de eso puede ser: `-Daily`, `-DaysOfWeek`, `-AtStartup`, `-AtLogOn`.
+ `-At` Especifica día y fecha para disparar la tarea
+ `-RepetitionDuration`  Especifica cuánto tiempo se repite el patrón de repetición después de que comienza la tarea.
+ `-RepetitionInterval` Especifica el tiempo que pasará antes de repetir nuevamente la tarea
+ `-RandomDelay` especifica cuánto tiempo de delay tendrá nuestra tarea(?)
+ (Ver más en Información complementaria)

### 3) Se registra la tarea

Registramos la tarea

``` powershell
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "testest" -Description "Updates"
```
+ `-Action` es la acción a ejecutar 
+ `-Trigger` es el disparador
+ `-TaskName` es el nombre de la tarea
+ `-Description` la descripcion de la tarea

## B) Ejemplos de tareas programadas

1.- Tarea que abre desde las 7am y luego cada minuto el programa notepad

```powershell
$action = New-ScheduledTaskAction -Execute "notepad.exe"
$trigger = New-ScheduledTaskTrigger -Once -At 7am -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "abre_notepad" -Description "Abre el notepad cada minuto"
```
+ Solamente abre uno nuevo cuando está cerrado

2.- Tarea que abre desde el momento en que se ejecuta el script y luego cada minuto la calculadora

```powershell
$action = New-ScheduledTaskAction -Execute "calc.exe"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "abre_calc" -Description "Abre la calculadora cada minuto"
```

3.- Tarea que ejecuta un script ubicado en la raíz

``` powershell
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "powershell –ExecutionPolicy Bypass c:\main.ps1"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "script" -Description "Updates"
``` 
+ El problema de esto es que muestra la pantalla azul de powershell en que se ejecuta
+ Si tratamos de cambiar la ruta de nuestro script por una cuyo PATH contenga espacios, por ejemplo `$env:ProgramFiles` o `C:\Program Files\anything` nos lanzará un error ya que el Scheduled Task de Windows no procesará adecuadamente el espacio de `Program Files`.


4.- Tarea que nos permite ejecutar un script en rutas que contienen espacios.

``` powershell
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument "Set-Location 'C:\Program Files (x86)\backdoor_program'; powershell –ExecutionPolicy Bypass .\main.ps1;"

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "notepad" -Description "Updates"
```


## C) Removiendo Scheduled Task en Windows
Para remover las tareas programadas anteriormente solamente debemos seguir los siguientes pasos

1.- Listar y ubicar el nombre de la tarea programada que queramos borrar

```
Get-ScheduledTask
```

2.- Removemos una tarea programada anteriormente

``` powershell
Unregister-ScheduledTask -TaskName "Your_Task_Name" 
```

3.- Removemos una tarea programada anteriormente sin necesidad de confirmación

``` powershell
Unregister-ScheduledTask -TaskName "Your_Task_Name" -Confirm:$False
```

# Información complementaria

Ejecución de Scripts de powershell en modo Bypass
+ [Politica de Scripts Powershell en Windows 10](https://protegermipc.net/2018/11/22/permitir-la-ejecucion-de-scripts-powershell-en-windows-10/)

Scheduled Task Windows
+ [PowerShell create a scheduled task - Vídeo de Youtube](https://www.youtube.com/watch?v=izlIJTmUW0o)
+ [New-ScheduledTaskAction](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtaskaction?view=win10-ps)
+ [New-ScheduledTaskTrigger](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtasktrigger?view=win10-ps)
+ [scheduled-task-with-daily-trigger-and-repetition-interval](https://stackoverflow.com/questions/20108886/scheduled-task-with-daily-trigger-and-repetition-interval)