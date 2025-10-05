# --------------------------
# Base runtime image
# --------------------------
FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

# --------------------------
# Build stage
# --------------------------
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy project file only for restore
COPY ["Reservo.EmailConsumer/Reservo.EmailConsumer.csproj", "Reservo.EmailConsumer/"]
COPY ["Reservo.Contracts/", "Reservo.Contracts/"]

# Restore packages
RUN dotnet restore "./Reservo.EmailConsumer/Reservo.EmailConsumer.csproj"

# Copy all source files
COPY ["Reservo.Contracts/", "Reservo.Contracts/"]
COPY ["Reservo.EmailConsumer/", "Reservo.EmailConsumer/"]

# Build
WORKDIR "/src/Reservo.EmailConsumer"
RUN dotnet build "./Reservo.EmailConsumer.csproj" -c $BUILD_CONFIGURATION -o /app/build

# --------------------------
# Publish stage
# --------------------------
FROM build AS publish
RUN dotnet publish "./Reservo.EmailConsumer.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# --------------------------
# Final image
# --------------------------
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Reservo.EmailConsumer.dll"]
