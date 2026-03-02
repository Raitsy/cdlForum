FROM tomcat:10.1-jdk17

COPY target/your-app.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080