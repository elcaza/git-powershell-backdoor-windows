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

# Entorno
El entorno en que ha sido probado este script fue
+ Windows 10
+ Debian 10