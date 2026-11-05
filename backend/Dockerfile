# syntax=docker/dockerfile:1
FROM maven:3.9-eclipse-temurin-17 AS development
WORKDIR /workspace
COPY pom.xml ./
COPY src ./src
EXPOSE 8080
CMD ["mvn", "-B", "-ntp", "spring-boot:run"]

FROM development AS build
RUN --mount=type=cache,target=/root/.m2 mvn -B -ntp verify

FROM eclipse-temurin:17-jre-jammy AS production
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system app \
    && useradd --system --gid app --home-dir /app app
WORKDIR /app
COPY --from=build --chown=app:app /workspace/target/doclens-backend.jar ./app.jar
USER app
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
