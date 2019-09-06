# Imagem usada para a fase de construÃ§Ã£o (restaurar, compilar, testar)
FROM maven:3.5.4-jdk-8 AS build
WORKDIR /src
EXPOSE 80 443

# Argumentos necessÃ¡rios para a compilaÃ§Ã£o do projeto
ARG MAVEN_REGISTRY=http://repo.maven.apache.org/maven2
ARG PROXY_ACTIVE=false
ARG PROXY_PROTOCOL=http
ARG PROXY_HOST=proxy.local
ARG PROXY_PORT=3128
ARG PROXY_USERNAME
ARG PROXY_PASSWORD

ARG SONARQUBE_HOST=http://sonarqube.tjmt.jus.br:9000
ENV SONARQUBE_HOST=$SONARQUBE_HOST

# Instalar e configurar ferramentas
RUN echo "<settings><mirrors><mirror><id>MAVEN_REGISTRY</id><name>MAVEN_REGISTRY</name><url>${MAVEN_REGISTRY}</url><mirrorOf>*</mirrorOf></mirror></mirrors><proxies><proxy><id>PROXY</id><active>${PROXY_ACTIVE}</active><protocol>${PROXY_PROTOCOL}</protocol><host>${PROXY_HOST}</host><port>${PROXY_PORT}</port><username>${PROXY_USERNAME}</username><password>${PROXY_PASSWORD}</password><nonProxyHosts></nonProxyHosts></proxy></proxies></settings>" > /usr/share/maven/conf/settings.xml

# Restaurar os pacotes
COPY pom.xml .
RUN mvn package -Dmaven.test.skip=true -Dspring-boot.repackage.skip=true



# Compilar o projeto
COPY . .
RUN mvn package -Dmaven.test.skip.exec=$SKIP_TEST
RUN cp target/*.jar ./app.jar

ENTRYPOINT mvn test -Dsonar.host.url=$SONARQUBE_HOST
 
# Imagem usada para a fase de execuÃ§Ã£o (executar)
FROM openjdk:8-jre AS final
WORKDIR /app
COPY --from=build /src/app.jar /app
EXPOSE 80 443
ENTRYPOINT exec java -jar app.jar