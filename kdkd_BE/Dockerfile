# build
FROM gradle:8.9-jdk17 AS build
WORKDIR /workspace
COPY . .
# BuildKit cache
RUN --mount=type=cache,target=/root/.gradle \
    gradle --no-daemon clean bootJar -x test

# runtime
FROM eclipse-temurin:17-jre-jammy
ENV TZ=Asia/Seoul
WORKDIR /app
COPY --from=build /workspace/build/libs/*.jar /app/app.jar

EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=10 CMD curl -fsS http://127.0.0.1:8080/actuator/health || exit 1
ENTRYPOINT ["java","-jar","/app/app.jar"]
