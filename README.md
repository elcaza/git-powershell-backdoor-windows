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
El entorno en que ha sido probado este script fue
+ Windows 10
+ Debian 10

# Anexo 1: ScheduledTask en Windows

Las tareas programadas son lo que nos permiten hacer que nuestro backdoor se ejecute de forma periódica.

## A) Forma básica en que esto sucede


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

## B) Ejemplos de acciones programadas

Tarea que abre desde las 7am y luego cada minuto notepad
```powershell
$action = New-ScheduledTaskAction -Execute "notepad.exe"
$trigger = New-ScheduledTaskTrigger -Once -At 7am -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "testest" -Description "Updates"
```
+ Solamente abre uno nuevo cuando está cerrado


# Información complementaria
Tareas Programadas
[New-ScheduledTaskAction](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtaskaction?view=win10-ps)
[New-ScheduledTaskTrigger](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtasktrigger?view=win10-ps)