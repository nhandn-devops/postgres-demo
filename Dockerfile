FROM --platform=linux/amd64 openjdk:11
EXPOSE 8080
ARG JAR_FILE=target/postgres-demo-0.0.1-SNAPSHOT.jar
ADD ${JAR_FILE} postgres-demo.jar
ENTRYPOINT ["java","-jar","/postgres-demo.jar"]