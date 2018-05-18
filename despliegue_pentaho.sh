# Modificado por Jportillo 18/04/18
# Configuramos DNS virtual
rm /etc/resolv.conf
ln -s ../run/resolvconf/resolv.conf /etc/resolv.conf
resolvconf -u

# Actualizamos cache paqueteria
apt-get update
# Actualizamos el sistema packages
apt-get upgrade -y

# Instalacion de zip para trabajar con pentaho
apt-get install unzip -y

# Instalacion y configuracion  Oracle Java 8
add-apt-repository ppa:webupd8team/java
apt-get update
# Disable prompting
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
apt-get install oracle-java8-installer -y

# Instalacion motor PostgreSQL
apt-get install postgresql -y

# Despliegue de pentaho
wget https://sourceforge.net/projects/pentaho/files/Business%20Intelligence%20Server/6.0/biserver-ce-6.0.1.0-386.zip
mkdir -p /opt/pentaho
unzip biserver-ce-6.0.1.0-386.zip -d /opt/pentaho

# Cambiamos el detella en   pg_hba.conf
sed -i s/"local   all             all                                     peer"/"local   all             all                                     trust"/g /etc/postgresql/9.5/main/pg_hba.conf

# creación usuario pentaho
useradd pentaho_user

# Refrescamos el servicio
systemctl restart postgresql

# Sql necesario para funcionamiento
sudo -u postgres psql -a -f /opt/pentaho/biserver-ce/data/postgresql/create_jcr_postgresql.sql
sudo -u postgres psql -a -f /opt/pentaho/biserver-ce/data/postgresql/create_repository_postgresql.sql
sudo -u postgres psql -a -f /opt/pentaho/biserver-ce/data/postgresql/create_quartz_postgresql.sql
sudo -u postgres psql -a quartz -c 'CREATE TABLE "QRTZ"(NAME VARCHAR(200) NOT NULL,PRIMARY KEY (NAME));'

# Descarga y copia de PostgreSQL JDBC driver
cd /usr/share/java
wget jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc4.jar

# Enlace simbolico
ln -s postgresql-9.3-1102.jdbc4.jar postgresql-9.3-jdbc4.jar

# Enlace simbolico para Pentaho's Tomcat folder
cd /opt/pentaho/biserver-ce/tomcat/lib
ln -s /usr/share/java/postgresql-9.3-jdbc4.jar postgresql-9.3-jdbc4.jar

# Pentaho context.xml configuracion extraido de foros
sed -i s/"org.hsqldb.jdbcDriver"/"org.postgresql.Driver"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"jdbc:hsqldb:hsql:\/\/localhost\/hibernate"/"jdbc:postgresql:\/\/localhost:5432\/hibernate"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"select count(\*) from INFORMATION_SCHEMA.SYSTEM_SEQUENCES"/"select 1"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"org.hsqldb.jdbcDriver"/"org.postgresql.Driver"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"jdbc:hsqldb:hsql:\/\/localhost\/quartz"/"jdbc:postgresql:\/\/localhost:5432\/quartz"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"select count(\*) from INFORMATION_SCHEMA.SYSTEM_SEQUENCES"/"select 1"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml

# Configuracion para pesistencia applicationContext-spring-security-hibernate.properties
sed -i s/"org.hsqldb.jdbcDriver"/"org.postgresql.Driver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties
sed -i s/"jdbc:hsqldb:hsql:\/\/localhost\/hibernate"/"jdbc:postgresql:\/\/localhost:5432\/hibernate"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties

# Pentaho hibernate-settings.xml
sed -i s/"system\/hibernate\/hsql.hibernate.cfg.xml"/"system\/hibernate\/postgresql.hibernate.cfg.xml"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/hibernate/hibernate-settings.xml

# Pentaho jdbc.properties
sed -i s/"SampleData\/type=javax.sql.DataSource"/"#SampleData\/type=javax.sql.DataSource"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleData\/driver=org.hsqldb.jdbcDriver"/"#SampleData\/driver=org.hsqldb.jdbcDriver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleData\/url=jdbc:hsqldb:hsql:\/\/localhost\/sampledata"/"#SampleData\/url=jdbc:hsqldb:hsql:\/\/localhost\/sampledata"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleData\/user=pentaho_user"/"#SampleData\/user=pentaho_user"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleData\/password=password"/"#SampleData\/password=password"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Hibernate\/driver=org.hsqldb.jdbcDriver"/"Hibernate\/driver=org.postgresql.Driver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Hibernate\/url=jdbc:hsqldb:hsql:\/\/localhost\/hibernate"/"Hibernate\/url=jdbc:postgresql:\/\/localhost:5432\/hibernate"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Quartz\/driver=org.hsqldb.jdbcDriver"/"Quartz\/driver=org.postgresql.Driver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Quartz\/url=jdbc:hsqldb:hsql:\/\/localhost\/quartz"/"Quartz\/url=jdbc:postgresql:\/\/localhost:5432\/quartz"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/type=javax.sql.DataSource"/"#Shark\/type=javax.sql.DataSource"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/driver=org.hsqldb.jdbcDriver"/"#Shark\/driver=org.hsqldb.jdbcDriver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/url=jdbc:hsqldb:hsql:\/\/localhost\/shark"/"#Shark\/url=jdbc:hsqldb:hsql:\/\/localhost\/shark"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/user=sa"/"#Shark\/user=sa"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/password="/"#Shark\/password="/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/type=javax.sql.DataSource"/"#SampleDataAdmin\/type=javax.sql.DataSource"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/driver=org.hsqldb.jdbcDriver"/"#SampleDataAdmin\/driver=org.hsqldb.jdbcDriver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/url=jdbc:hsqldb:hsql:\/\/localhost\/sampledata"/"#SampleDataAdmin\/url=jdbc:hsqldb:hsql:\/\/localhost\/sampledata"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/user=pentaho_admin"/"#SampleDataAdmin\/user=pentaho_admin"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/password=password"/"#SampleDataAdmin\/password=password"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties

# Permisos
chmod +x /opt/pentaho/biserver-ce/*.sh

# Instalacion del servicio en systema
cp /vagrant/pentaho-bi.service /etc/systemd/system/
# activacion del servicio startup
sudo su -i systemctl enable pentaho-bi.service
# Start pentaho
sudo su -i systemctl start pentaho-bi.service
