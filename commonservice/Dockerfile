# build stage
FROM eclipse-temurin:21-jdk-jammy as builder
WORKDIR /tempspace/app

# copy build files
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# build the application
RUN ./mvnw install -DskipTests

# run stage
FROM eclipse-temurin:21-jdk-jammy
LABEL maintainer="gilang.grk17@gmail.com"
WORKDIR /app

# copy the built JAR from the build stage
COPY --from=builder /tempspace/app/target/*.jar app.jar

# run the application
EXPOSE 10001
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]
