FROM nginx:alpine

LABEL org.opencontainers.image.title="my-workstation-web"

ENV APP_ENV=development

COPY app/ /usr/share/nginx/html/

EXPOSE 80
