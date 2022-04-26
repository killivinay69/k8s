FROM mcr.microsoft.com/dotnet/core/sdk:3.1
ENV ASPNETCORE_URLS http://*:80

ENV ASPNETCORE_ENVIRONMENT=Development

EXPOSE 80
WORKDIR /src
COPY . apibuilder
RUN dotnet restore apibuilder/Glams.ApiBuilder.API/Glams.ApiBuilder.API/Glams.ApiBuilder.API.csproj

COPY . .
WORKDIR /src/apibuilder/

VOLUME /glams/library/api
VOLUME /glams/publish/api

RUN dotnet build /src/apibuilder/Glams.ApiBuilder.API/Glams.ApiBuilder.API/Glams.ApiBuilder.API.csproj -c Release -o /app
COPY ./launchSettings.json /app/launchSettings.json

WORKDIR /app
ENTRYPOINT ["dotnet", "Glams.ApiBuilder.API.dll","--urls", "http://*:80"]