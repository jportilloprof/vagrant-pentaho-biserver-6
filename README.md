## vagrant-pentaho-biserver-6
## Despliegue de pentaho BiServer-6 con Java 8

* Ubuntu Xenial64
* PostgreSQL 9.5
* Pentaho BI Server 6
* Oracle JDK 8

## Requerimientos mínimos

Vagrant 2.0.2 o superior

## Configuracíon

Puedes modificatr tu **Vagrantfile** para aumentar la memoria, para la versión de pentaho he optado por la configuración minima necesaria para un despliegue correcto.

## Uso

* Clona este repositorio
* Posicionate en el directorio 
* Ejecuta *vagrant up*

## Tiempo de provisión del sistema: Estimado en 10 m según conexión

## Posibles problemas: 

No se activa el servicio por defecto:

* vagrant ssh default
* sudo -i
* cd /opt/pentaho/biserver-ce/start-pentaho.sh 
* ./start-pentaho.sh

Una vez desplegado navega en [http://localhost:8080]. Para acceder usuario *admin* y *password*. 
Disfruta y rompe lo que quieras ;-)
