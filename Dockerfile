FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["TesteTecnico/TesteTecnico.csproj", "TesteTecnico/"]
RUN dotnet restore "TesteTecnico/TesteTecnico.csproj"

COPY . .
WORKDIR /src/TesteTecnico
RUN dotnet publish "TesteTecnico.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

RUN mkdir -p /app/data && chown -R $APP_UID /app
USER $APP_UID

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "TesteTecnico.dll"]
