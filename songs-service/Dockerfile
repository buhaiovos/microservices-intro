# Smaller OS footprint using JRE
FROM eclipse-temurin:27-jre
WORKDIR /app

ADD build/libs/*.jar /app/app.jar

CMD ["java", "-jar", "app.jar"]