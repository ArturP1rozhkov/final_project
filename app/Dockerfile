# app/Dockerfile

# версия и дата подставляются в страницу на сборке
FROM alpine:3.20 AS build

ARG APP_VERSION=dev
ARG BUILD_DATE=unknown

WORKDIR /src
COPY index.html .
RUN sed -e "s/__VERSION__/${APP_VERSION}/g" \
        -e "s/__DATE__/${BUILD_DATE}/g" \
        index.html > /index.html

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /index.html /usr/share/nginx/html/index.html

EXPOSE 8080
