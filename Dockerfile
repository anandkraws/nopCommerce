# syntax=docker/dockerfile:1.4

### --- Build Stage ---
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build

# Set working directory
WORKDIR /src

# Copy source code and NuGet config
COPY ./src/ ./
COPY nuget.config ./nuget.config

# Install envsubst
RUN apk add --no-cache gettext

# Secure restore with BuildKit secrets
RUN --mount=type=secret,id=jf_username \
    --mount=type=secret,id=jf_token \
    export JF_USERNAME=$(cat /run/secrets/jf_username) && \
    export JF_TOKEN=$(cat /run/secrets/jf_token) && \
    envsubst < nuget.config > nuget.config.subst && \
    cat nuget.config.subst && \
    dotnet restore NopCommerce.sln --configfile nuget.config.subst && \
    rm nuget.config.subst

# Build the solution
RUN dotnet build NopCommerce.sln --no-incremental -c Release

# Publish Nop.Web
WORKDIR /src/Presentation/Nop.Web
RUN dotnet publish Nop.Web.csproj -c Release -o /app/published

# Setup directories and permissions
WORKDIR /app/published

RUN mkdir logs bin && \
    chmod 775 App_Data \
              App_Data/DataProtectionKeys \
              bin \
              logs \
              Plugins \
              wwwroot/bundles \
              wwwroot/db_backups \
              wwwroot/files/exportimport \
              wwwroot/icons \
              wwwroot/images \
              wwwroot/images/thumbs \
              wwwroot/images/uploaded \
              wwwroot/sitemaps


### --- Runtime Stage ---
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime

# Install required dependencies
RUN apk add --no-cache icu-libs icu-data-full \
    && apk add tiff libgdiplus libc-dev tzdata --no-cache \
    --repository http://dl-3.alpinelinux.org/alpine/edge/main/ \
    --repository http://dl-3.alpinelinux.org/alpine/edge/community/

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

WORKDIR /app

# Copy published output
COPY --from=build /app/published .

ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
