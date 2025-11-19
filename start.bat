@echo off
echo ================================================
echo   Sistema de Gestao de Avisos - Bernhoeft GRT
echo   Iniciando Backend e Frontend
echo ================================================
echo.

echo [1/4] Verificando instalacoes...
where dotnet >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERRO: .NET 9 nao encontrado!
    echo Baixe em: https://dotnet.microsoft.com/download/dotnet/9.0
    pause
    exit /b 1
)

where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERRO: Node.js nao encontrado!
    echo Baixe em: https://nodejs.org/
    pause
    exit /b 1
)

echo OK - .NET e Node.js encontrados
echo.

echo [2/4] Restaurando dependencias do Backend...
dotnet restore
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao restaurar dependencias!
    pause
    exit /b 1
)
echo OK - Dependencias restauradas
echo.

echo [3/4] Instalando dependencias do Frontend...
cd 5-Web\avisos-frontend
if not exist node_modules (
    echo Instalando pacotes NPM...
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo ERRO ao instalar pacotes NPM!
        pause
        exit /b 1
    )
)
cd ..\..
echo OK - Frontend pronto
echo.

echo [4/4] Iniciando aplicacao...
echo.
echo ================================================
echo   Aplicacao iniciada com sucesso!
echo ================================================
echo.
echo API Backend:  http://localhost:5001
echo Swagger:      http://localhost:5001/swagger
echo Frontend:     http://localhost:3001
echo.
echo Pressione Ctrl+C em cada janela para parar
echo ================================================
echo.

start "Bernhoeft GRT - Backend API" cmd /k "cd 1-Presentation\Bernhoeft.GRT.Teste.Api && dotnet run"
timeout /t 5 /nobreak >nul
start "Bernhoeft GRT - Frontend" cmd /k "cd 5-Web\avisos-frontend && npm run dev"

echo.
echo Abrindo navegador em 10 segundos...
timeout /t 10 /nobreak >nul
start http://localhost:5000/swagger
timeout /t 2 /nobreak >nul
start http://localhost:3000

echo.
echo Tudo pronto! Boa apresentacao!
pause
