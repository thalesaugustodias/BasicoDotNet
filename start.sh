#!/bin/bash

echo "================================================"
echo "  Sistema de Gestao de Avisos - Bernhoeft GRT"
echo "  Iniciando Backend e Frontend"
echo "================================================"
echo ""

echo "[1/4] Verificando instalacoes..."
if ! command -v dotnet &> /dev/null; then
    echo "ERRO: .NET 9 nao encontrado!"
    echo "Baixe em: https://dotnet.microsoft.com/download/dotnet/9.0"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "ERRO: Node.js nao encontrado!"
    echo "Baixe em: https://nodejs.org/"
    exit 1
fi

echo "OK - .NET e Node.js encontrados"
echo ""

echo "[2/4] Restaurando dependencias do Backend..."
dotnet restore
if [ $? -ne 0 ]; then
    echo "ERRO ao restaurar dependencias!"
    exit 1
fi
echo "OK - Dependencias restauradas"
echo ""

echo "[3/4] Instalando dependencias do Frontend..."
cd 5-Web/avisos-frontend
if [ ! -d "node_modules" ]; then
    echo "Instalando pacotes NPM..."
    npm install
    if [ $? -ne 0 ]; then
        echo "ERRO ao instalar pacotes NPM!"
        exit 1
    fi
fi
cd ../..
echo "OK - Frontend pronto"
echo ""

echo "[4/4] Iniciando aplicacao..."
echo ""
echo "================================================"
echo "  Aplicacao iniciada com sucesso!"
echo "================================================"
echo ""
echo "API Backend:  http://localhost:5001"
echo "Swagger:      http://localhost:5001/swagger"
echo "Frontend:     http://localhost:3001"
echo ""
echo "Pressione Ctrl+C em cada terminal para parar"
echo "================================================"
echo ""

# Inicia backend em background
cd 1-Presentation/Bernhoeft.GRT.Teste.Api
dotnet run &
BACKEND_PID=$!
cd ../..

# Espera 5 segundos
sleep 5

# Inicia frontend em background
cd 5-Web/avisos-frontend
npm run dev &
FRONTEND_PID=$!
cd ../..

echo ""
echo "Processos iniciados:"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "Para parar: kill $BACKEND_PID $FRONTEND_PID"
echo ""
echo "Abrindo navegador em 10 segundos..."
sleep 10

# Abre navegador (funciona em macOS e Linux com xdg-open)
if command -v open &> /dev/null; then
    open http://localhost:5001/swagger
    sleep 2
    open http://localhost:3000
elif command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:5001/swagger
    sleep 2
    xdg-open http://localhost:3001
fi

echo ""
echo "Tudo pronto! Boa apresentacao!"
echo ""

# Aguarda Ctrl+C
wait
