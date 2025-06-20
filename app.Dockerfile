# syntax=docker/dockerfile:1.4

### --- Build Stage ---
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build

WORKDIR /src
COPY ./src/ ./
COPY nuget.config ./nuget.config

RUN apk add --no-cache gettext

RUN dotnet restore NopCommerce.sln

RUN dotnet build NopCommerce.sln --no-incremental -c Release

WORKDIR /src/Presentation/Nop.Web
RUN dotnet publish Nop.Web.csproj -c Release -o /app/published

WORKDIR /app/published
RUN mkdir logs bin && \
    chmod 775 App_Data \
              App_Data/DataProtectionKeys \
              bin logs Plugins \
              wwwroot/bundles wwwroot/db_backups \
              wwwroot/files/exportimport wwwroot/icons \
              wwwroot/images wwwroot/images/thumbs \
              wwwroot/images/uploaded wwwroot/sitemaps

### --- Runtime Stage ---
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime

RUN apk add --no-cache icu-libs icu-data-full \
    && apk add tiff libgdiplus libc-dev tzdata --no-cache \
    --repository http://dl-3.alpinelinux.org/alpine/edge/main/ \
    --repository http://dl-3.alpinelinux.org/alpine/edge/community/

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

WORKDIR /app
COPY --from=build /app/published .

ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]

