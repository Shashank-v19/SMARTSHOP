# ==========================================
# Multi-stage Dockerfile for SMARTSHOP App
# ==========================================

# Stage 1: Build the WAR with Maven
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run with Apache Tomcat 10
FROM tomcat:10.1-jdk21-temurin
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR (finalName in pom.xml is 'smartshop')
COPY --from=build /app/target/smartshop.war /usr/local/tomcat/webapps/ROOT.war

# DB credentials are passed as environment variables at runtime
# e.g.: docker run -e DB_URL=... -e DB_USER=... -e DB_PASSWORD=... smartshop
ENV DB_URL=""
ENV DB_USER=""
ENV DB_PASSWORD=""

EXPOSE 8080
CMD ["catalina.sh", "run"]
