FROM eclipse-temurin:21-jre

WORKDIR /app

RUN groupadd --gid 10001 appgroup \
    && useradd --uid 10001 --gid appgroup --no-create-home --shell /usr/sbin/nologin usuario

COPY target/pedidos-api-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

USER usuario

ENTRYPOINT ["java", "-jar", "app.jar"]