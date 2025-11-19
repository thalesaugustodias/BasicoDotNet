# 🔔 Sistema de Gestão de Avisos - Bernhoeft GRT

[![.NET](https://img.shields.io/badge/.NET-9.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![Vue.js](https://img.shields.io/badge/Vue.js-3.5-4FC08D?logo=vue.js)](https://vuejs.org/)
[![PrimeVue](https://img.shields.io/badge/PrimeVue-4.0-41B883?logo=vue.js)](https://primevue.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Sistema completo de gestão de avisos desenvolvido como parte do teste técnico para vaga de Desenvolvedor C# na Bernhoeft.

## 📑 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Tecnologias](#-tecnologias)
- [Arquitetura](#-arquitetura)
- [Como Executar](#-como-executar)
- [Endpoints da API](#-endpoints-da-api)
- [Documentação](#-documentação)

## 🎯 Sobre o Projeto

Sistema de gestão de avisos com funcionalidades CRUD completas, controle de auditoria, soft delete e interface web moderna. Desenvolvido seguindo princípios de Clean Architecture, SOLID e DDD.

### Diferenciais

- ✨ **Arquitetura Limpa** - Clean Architecture com separação em camadas
- 🎨 **Interface Moderna** - Vue.js 3 + PrimeVue 4
- 📊 **Auditoria** - Controle de criação e edição
- 🔄 **CQRS** - Separação de comandos e consultas
- 🛡️ **Validações Robustas** - FluentValidation integrado
- 🗑️ **Soft Delete** - Exclusão lógica preservando histórico

## ✨ Funcionalidades

### Backend (.NET API)

- [x] Listagem de avisos ativos
- [x] Consulta de aviso por ID
- [x] Criação de novos avisos
- [x] Atualização de mensagem (título preservado)
- [x] Exclusão lógica (soft delete)
- [x] Controle de auditoria (CriadoEm, EditadoEm)
- [x] Validações automáticas com FluentValidation
- [x] Documentação Swagger/OpenAPI
- [x] Versionamento de API (v1)

### Frontend (Vue.js)

- [x] Interface responsiva e moderna
- [x] Listagem com paginação e ordenação
- [x] Criação de avisos via modal
- [x] Edição de mensagem (regra de negócio)
- [x] Exclusão com confirmação
- [x] Notificações toast
- [x] Validação client-side
- [x] Visualização de dados de auditoria
- [x] Tags de status (Ativo/Inativo)

## 🚀 Tecnologias

### Backend

- **.NET 9** - Framework principal
- **ASP.NET Core** - Web API
- **Entity Framework Core** - ORM (InMemory Database)
- **MediatR** - CQRS e Mediator Pattern
- **FluentValidation** - Validações
- **Swashbuckle** - Documentação API

### Frontend

- **Vue.js 3** - Framework progressivo
- **PrimeVue 4** - UI Component Library
- **Vite** - Build tool
- **Axios** - HTTP Client
- **Vue Router** - Roteamento

## 🏗️ Arquitetura

```
📦 Bernhoeft.GRT.Teste
├── 📁 1-Presentation
│   └── 📁 Api                          # Controllers e configuração
├── 📁 2-Application
│   ├── Handlers/                       # CQRS Handlers
│   ├── Requests/                       # Commands e Queries
│   ├── Responses/                      # DTOs
│   └── Validators/                     # Validadores FluentValidation
├── 📁 3-Domain
│   ├── Entities/                       # Entidades de domínio
│   └── Interfaces/Repositories/        # Contratos
├── 📁 4-Infra
│   └── 📁 Persistence.InMemory
│       ├── Repositories/               # Implementações
│       └── Mappings/                   # EF Core Mappings
└── 📁 5-Web
    └── 📁 avisos-frontend              # Aplicação Vue.js
```

### Padrões Implementados

- **Clean Architecture** - Separação em camadas
- **CQRS** - Separação de leitura e escrita
- **Repository Pattern** - Abstração de dados
- **Mediator Pattern** - Desacoplamento
- **Dependency Injection** - Inversão de controle
- **Unit of Work** - Transações via DbContext

## 🎮 Como Executar

### Pré-requisitos

- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- [Node.js 18+](https://nodejs.org/)
- IDE recomendada: Visual Studio 2022 ou VS Code

### Backend

```bash
# Clone o repositório
git clone https://github.com/thalesaugustodias/BasicoDotNet
cd BasicoDotNet

# Restaure as dependências
dotnet restore

# Execute a API
cd 1-Presentation/Bernhoeft.GRT.Teste.Api
dotnet run

# API disponível em:
# http://localhost:5001
# Swagger: http://localhost:5001/swagger
```

### Frontend

```bash
# Navegue para o frontend
cd 5-Web/avisos-frontend

# Instale as dependências
npm install

# Execute o servidor de desenvolvimento
npm run dev

# Aplicação disponível em:
# http://localhost:3001
```

## 📡 Endpoints da API

### Base URL: `http://localhost:5001/api/v1`

| Método | Endpoint | Descrição | Status Codes |
|--------|----------|-----------|--------------|
| GET | `/avisos` | Lista todos os avisos ativos | 200, 204 |
| GET | `/avisos/{id}` | Retorna aviso específico | 200, 400, 404 |
| POST | `/avisos` | Cria novo aviso | 201, 400 |
| PUT | `/avisos/{id}` | Atualiza mensagem | 200, 400, 404 |
| DELETE | `/avisos/{id}` | Exclui aviso (soft delete) | 200, 400, 404 |

### Exemplos de Requisição

#### Criar Aviso (POST)

```json
POST /api/v1/avisos
{
  "Titulo": "Manutenção Programada",
  "Mensagem": "Sistema estará em manutenção no dia 15/12/2024."
}
```

#### Atualizar Aviso (PUT)

```json
PUT /api/v1/avisos/1
{
  "Mensagem": "Mensagem atualizada do aviso"
}
```

## 📚 Documentação

### Swagger/OpenAPI

Acesse a documentação interativa da API em:
```
http://localhost:5001/swagger
```

### Documentação Técnica Completa

Para detalhes sobre decisões arquiteturais, padrões aplicados e justificativas técnicas, consulte:

📄 **[DOCUMENTACAO_TECNICA.md](DOCUMENTACAO_TECNICA.md)**

Este documento inclui:
- Decisões arquiteturais detalhadas
- Justificativas de padrões aplicados
- Diagramas e estruturas
- Próximos passos e melhorias
- Guia para apresentação técnica

## 🔒 Validações Implementadas

### Regras de Negócio

- ✅ ID deve ser maior que zero
- ✅ Título obrigatório (máx. 50 caracteres)
- ✅ Mensagem obrigatória
- ✅ Apenas mensagem editável no PUT
- ✅ Soft delete preserva histórico
- ✅ Queries retornam apenas registros ativos

### Auditoria

Todos os avisos possuem:
- `CriadoEm` - Data/hora de criação (UTC)
- `EditadoEm` - Data/hora da última edição (UTC, nullable)
- `Ativo` - Flag para soft delete

## 🛠️ Melhorias Futuras

- [ ] Migração para SQL Server
- [ ] Autenticação e autorização (JWT)
- [ ] Cache com Redis
- [ ] Logs estruturados (Serilog)
- [ ] CI/CD pipeline
- [ ] Docker containers
- [ ] Health checks
- [ ] Rate limiting

## 👨‍💻 Autor

**Thales Augusto De Lima Dias**

- GitHub: [@thalesaugustodias](https://github.com/thalesaugustodias)
- LinkedIn: [thalesaugustodias](https://www.linkedin.com/in/thales-augusto-dias-3b03b5199/)
- Email: thalesaugustodias98@gmail.com

## 📄 Licença

Este projeto foi desenvolvido como parte de um teste técnico para a Bernhoeft.

---

**Desenvolvido para o Teste Técnico Bernhoeft GRT**

*Demonstrando conhecimento em .NET 9, Clean Architecture, CQRS, DDD, Vue.js 3 e boas práticas de desenvolvimento*
