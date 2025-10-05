# --------------------------
# Base runtime image
# --------------------------
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 5113
USER $APP_UID
ENV ASPNETCORE_URLS=http://+:5113/

# --------------------------
# Build stage
# --------------------------
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy only project files first (for restore cache)
COPY ["Reservo.API/Reservo.API.csproj", "Reservo.API/"]
COPY ["Reservo.Model/Reservo.Model.csproj", "Reservo.Model/"]
COPY ["Reservo.Services/Reservo.Services.csproj", "Reservo.Services/"]
COPY ["Reservo.EmailConsumer/Reservo.EmailConsumer.csproj", "Reservo.EmailConsumer/"]
COPY ["Reservo.Contracts/", "Reservo.Contracts/"]
# Add other projects your API depends on here

# Restore packages
RUN dotnet restore "Reservo.API/Reservo.API.csproj"

# Copy source code after restore
COPY ["Reservo.API/", "Reservo.API/"]
COPY ["Reservo.Model/", "Reservo.Model/"]
COPY ["Reservo.Services/", "Reservo.Services/"]
COPY ["Reservo.EmailConsumer/", "Reservo.EmailConsumer/"]
COPY ["Reservo.Contracts/", "Reservo.Contracts/"]

# Build
WORKDIR "/src/Reservo.API"
RUN dotnet build "Reservo.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

# --------------------------
# Publish stage
# --------------------------
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Reservo.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# --------------------------
# Final image
# --------------------------
FROM base AS final
WORKDIR /app

# Copy published app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "Reservo.API.dll"]


