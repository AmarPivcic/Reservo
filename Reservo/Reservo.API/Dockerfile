#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Reservo.API/Reservo.API.csproj", "Reservo.API/"]
COPY ["Reservo.Model/Reservo.Model.csproj", "Reservo.Model/"]
COPY ["Reservo.Services/Reservo.Services.csproj", "Reservo.Services/"]
RUN dotnet restore "./Reservo.API/Reservo.API.csproj"
COPY . .
WORKDIR "/src/Reservo.API"
RUN dotnet build "./Reservo.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Reservo.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Reservo.API.dll"]