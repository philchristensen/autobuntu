# defaults for jenkins continuous integration server

# pulled in from the init script; makes things easier.
NAME=jenkins

# location of java
JAVA=/usr/bin/java

# arguments to pass to java
#JAVA_ARGS="-Xmx256m"
#JAVA_ARGS="-Djava.net.preferIPv4Stack=true" # make jenkins listen on IPv4 address
JAVA_ARGS="-Djava.io.tmpdir=/var/lib/jenkins/tmp -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York -XX:MaxPermSize=1024m"

PIDFILE=/var/run/jenkins/jenkins.pid

# user id to be invoked as (otherwise will run as root; not wise!)
JENKINS_USER=jenkins

# location of jenkins arch indep files
JENKINS_ROOT=/usr/share/jenkins

# location of the jenkins war file
JENKINS_WAR=/usr/share/jenkins/jenkins.war

# jenkins home location
JENKINS_HOME=/var/lib/jenkins

# jenkins /run location
JENKINS_RUN=/var/run/jenkins

# set this to false if you don't want Hudson to run by itself
# in this set up, you are expected to provide a servlet container
# to host jenkins.
RUN_STANDALONE=true

# log location.  this may be a syslog facility.priority
JENKINS_LOG=/var/log/jenkins/$NAME.log
#HUDSON_LOG=daemon.info

# OS LIMITS SETUP
#   comment this out to observe /etc/security/limits.conf
#   this is on by default because http://github.com/jenkinsci/jenkins/commit/2fb288474e980d0e7ff9c4a3b768874835a3e92e
#   reported that Ubuntu's PAM configuration doesn't include pam_limits.so, and as a result the # of file
#   descriptors are forced to 1024 regardless of /etc/security/limits.conf
MAXOPENFILES=8192

# port for HTTP connector (default 8080; disable with -1)
HTTP_PORT=8080

# port for AJP connector (disabled by default)
AJP_PORT=-1

# arguments to pass to jenkins.
# --javahome=$JAVA_HOME
# --httpPort=$HTTP_PORT (default 8080; disable with -1)
# --httpsPort=$HTTP_PORT
# --ajp13Port=$AJP_PORT
# --argumentsRealm.passwd.$ADMIN_USER=[password]
# --argumentsRealm.roles.$ADMIN_USER=admin
# --webroot=~/.jenkins/war
JENKINS_ARGS="--webroot=$JENKINS_RUN/war --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT"
