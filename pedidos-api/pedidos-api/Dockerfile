FROM eclipse-temurin:21.0.13_9-jdk-jammy@sha256:4b1a74fbffbe6b4e7b6f0171a472478282fb463790a51edf10e465d578f22b69 AS build
WORKDIR /workspace
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw
COPY src/ src/
# Tests use an isolated database; runtime still uses /data.
RUN ./mvnw -B -ntp -Dspring.datasource.url=jdbc:h2:mem:buildtest clean verify

FROM eclipse-temurin:21.0.13_9-jre-jammy@sha256:d4cbe963bb4f3a769d56473b32db2bfb46b0d4b29797c152815da692d9f9aab5 AS runtime
WORKDIR /app
RUN groupadd --gid 10001 appgroup \
    && useradd --uid 10001 --gid appgroup --no-create-home --shell /usr/sbin/nologin usuario \
    && mkdir /data && chown 10001:10001 /data
COPY --from=build --chown=10001:10001 /workspace/target/pedidos-api-0.0.1-SNAPSHOT.jar app.jar
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=70"
EXPOSE 8080
USER 10001:10001
ENTRYPOINT ["java", "-jar", "app.jar"]
