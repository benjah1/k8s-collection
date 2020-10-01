FROM openjdk:11

ADD ./ms /app
RUN cd /app && ls -al && sudo ./mvnw clean package && ls ./target


FROM openjdk:11

COPY --from=0 /app/target/ms.jar /opt/ms.jar
CMD ["java", "$JAVA_OPTS", "-jar", "/opt/ms.jar"]
