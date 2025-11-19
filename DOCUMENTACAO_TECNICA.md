# 📋 Documentação Técnica - Sistema de Gestão de Avisos
## Teste Técnico Bernhoeft GRT

**Candidato:** Thales Augusto Dias  
**Data:** Novembro - 2025,
**Stack:** .NET 9, Vue.js 3, PrimeVue 4

---

## 📌 Sumário Executivo

Este documento detalha a implementação completa do sistema de gestão de avisos, abordando decisões arquiteturais, padrões de design aplicados, funcionalidades implementadas e melhorias além do escopo original.

---

## 🎯 Requisitos Atendidos

### ✅ Requisitos Obrigatórios

1. **Endpoints CRUD Completo**
   - ✅ GET `/api/v1/avisos` - Lista todos os avisos ativos
   - ✅ GET `/api/v1/avisos/{id}` - Retorna aviso específico
   - ✅ POST `/api/v1/avisos` - Cria novo aviso
   - ✅ PUT `/api/v1/avisos/{id}` - Atualiza mensagem do aviso
   - ✅ DELETE `/api/v1/avisos/{id}` - Soft delete do aviso

2. **Controle de Auditoria**
   - ✅ Campo `CriadoEm` (DateTime) - Registra data/hora de criação
   - ✅ Campo `EditadoEm` (DateTime?) - Registra última edição

3. **Validações com FluentValidation**
   - ✅ Validação de ID > 0 para consultas
   - ✅ Validação de título e mensagem obrigatórios na criação
   - ✅ Validação de mensagem obrigatória na edição
   - ✅ Validação de tamanho máximo do título (50 caracteres)

4. **Soft Delete**
   - ✅ Campo `Ativo` (boolean) para controle
   - ✅ Exclusão lógica ao invés de física
   - ✅ Filtros automáticos para retornar apenas registros ativos

5. **Regras de Negócio**
   - ✅ Apenas mensagem editável no PUT
   - ✅ Título preservado após criação
   - ✅ Filtros retornam apenas avisos ativos

---

## 🏗️ Arquitetura e Padrões Implementados

### 1. **Clean Architecture / DDD**

A solução segue rigorosamente os princípios de Clean Architecture com separação em camadas:

```
📁 Estrutura de Camadas
├── 1-Presentation/                   # Camada de Apresentação
│   └── Api/                          # Controllers, DTOs de API
├── 2-Application/                    # Camada de Aplicação
│   ├── Handlers/                     # CQRS Handlers
│   ├── Requests/                     # Commands e Queries
│   ├── Responses/                    # DTOs de Resposta
│   └── Validators/                   # Validadores FluentValidation
├── 3-Domain/                         # Camada de Domínio
│   ├── Entities/                     # Entidades de Negócio
│   └── Interfaces/Repositories/      # Contratos de Repositório
├── 4-Infra/                          # Camada de Infraestrutura
│   └── Persistence.InMemory/         # Implementação EF Core InMemory
│       ├── Repositories/             # Implementações de Repositórios
│       └── Mappings/                 # Configurações EF Core
└── 5-Web/                            # Camada Web (Frontend)
    └── avisos-frontend/              # Vue.js 3 + PrimeVue
```

**Justificativa:**  
Esta separação garante alta coesão e baixo acoplamento, facilitando manutenção, testabilidade e evolução do código. Cada camada tem responsabilidade única e bem definida.

---

### 2. **CQRS (Command Query Responsibility Segregation)**

Implementado com MediatR para separar operações de leitura e escrita:

#### **Queries (Leitura)**
- `GetAvisosRequest` / `GetAvisosHandler` - Lista avisos ativos
- `GetAvisoRequest` / `GetAvisoHandler` - Busca aviso por ID

#### **Commands (Escrita)**
- `CreateAvisoRequest` / `CreateAvisoHandler` - Criação
- `UpdateAvisoRequest` / `UpdateAvisoHandler` - Atualização
- `DeleteAvisoRequest` / `DeleteAvisoHandler` - Exclusão lógica

**Justificativa:**  
CQRS permite otimização independente de operações de leitura e escrita, facilita cache strategies e melhora a escalabilidade. Queries podem usar tracking desabilitado para melhor performance.

---

### 3. **Repository Pattern**

Interface `IAvisoRepository` define o contrato, implementação em `AvisoRepository`:

```csharp
public interface IAvisoRepository : IRepository<AvisoEntity>
{
    Task<List<AvisoEntity>> ObterTodosAvisosAsync(...);
    Task<AvisoEntity?> ObterAvisoPorIdAsync(int id, ...);
    Task<List<AvisoEntity>> ObterAvisosAtivosAsync(...);
    Task<bool> VerificarSeExisteAtivoAsync(int id, ...);
}
```

**Justificativa:**  
Abstração da camada de dados permite trocar implementação (InMemory → SQL Server) sem impactar a lógica de negócio. Facilita testes unitários com mocks.

---

### 4. **Dependency Injection**

Uso extensivo de DI nativo do .NET:
- Repositórios injetados via `[InjectService]` attribute
- Handlers recebem `IServiceProvider` para lazy loading
- Controllers recebem `IMediator` automaticamente

**Justificativa:**  
DI nativo garante gerenciamento automático de ciclo de vida, facilita testes e promove baixo acoplamento.

---

### 5. **FluentValidation Pipeline**

Validators registrados e executados automaticamente pelo ASP.NET Core:

```csharp
ValidatorOptions.Global.DefaultClassLevelCascadeMode = CascadeMode.Stop;
ValidatorOptions.Global.DefaultRuleLevelCascadeMode = CascadeMode.Stop;
builder.Services.AddFluentValidationAutoValidation();
```

**Justificativa:**  
Validações são interceptadas antes de chegar nos handlers, retornando 400 Bad Request automaticamente. Reduz código boilerplate e centraliza regras de validação.

---

## 🔍 Decisões Técnicas Detalhadas

### 1. **Auditoria com DateTime.UtcNow**

```csharp
public DateTime CriadoEm { get; set; } = DateTime.UtcNow;
public DateTime? EditadoEm { get; set; }
```

**Por quê UTC?**
- Evita problemas com fusos horários
- Padrão para sistemas distribuídos
- Facilita sincronização entre servidores

**Por quê EditadoEm é nullable?**
- Diferencia registros nunca editados
- Economia de espaço em banco
- Semântica clara: null = nunca editado

---

### 2. **Soft Delete com Flag Ativo**

```csharp
public bool Ativo { get; set; } = true;

// No handler de delete:
aviso.Ativo = false;
aviso.EditadoEm = DateTime.UtcNow;
_avisoRepository.Update(aviso);
```

**Vantagens:**
- Preserva histórico para auditoria
- Permite restauração futura
- Mantém integridade referencial
- Facilita análises de dados

**Implementação:**
- Filtros em repositório garantem que queries retornem apenas ativos
- Método `ObterAvisosAtivosAsync()` já filtra
- `ObterAvisoPorIdAsync()` valida `Ativo = true`

---

### 3. **Tracking Behavior Explícito**

```csharp
Task<List<AvisoEntity>> ObterAvisosAtivosAsync(
    TrackingBehavior tracking = TrackingBehavior.Default, 
    CancellationToken cancellationToken = default
);
```

**Estratégia:**
- **NoTracking** para queries (leitura)
  - Melhor performance
  - Reduz overhead do Change Tracker
  - Ideal para DTOs
  
- **Default** (com tracking) para commands
  - Necessário para Update/Delete
  - Change Tracker detecta modificações
  - `SaveChanges()` aplica automaticamente

---

### 4. **Apenas Mensagem Editável**

Conforme requisito, apenas `Mensagem` pode ser editada:

```csharp
public class UpdateAvisoRequest : IRequest<IOperationResult>
{
    public int Id { get; set; }
    public string Mensagem { get; set; }  // Apenas mensagem
}

// No Handler:
aviso.Mensagem = request.Mensagem;
aviso.EditadoEm = DateTime.UtcNow;
// Título NÃO é modificado
```

**Justificativa da Regra:**
- Título identifica o aviso
- Mudá-lo poderia confundir usuários
- Mensagem é o conteúdo editável
- Se precisar novo título, deve criar novo aviso

---

### 5. **Implicit Operators para Mapeamento**

```csharp
public static implicit operator GetAvisoResponse(AvisoEntity entity) => new()
{
    Id = entity.Id,
    Ativo = entity.Ativo,
    Titulo = entity.Titulo,
    Mensagem = entity.Mensagem,
    CriadoEm = entity.CriadoEm,
    EditadoEm = entity.EditadoEm
};

// Uso:
return OperationResult<GetAvisoResponse>.ReturnOk((GetAvisoResponse)aviso);
```

**Vantagens:**
- Código limpo e conciso
- Performance melhor que AutoMapper para casos simples
- Type-safe em compile time
- Sem dependências externas

**Quando usar:**
- Mapeamentos 1:1 simples
- DTOs que refletem entidades
- Projetos pequenos/médios

---

## 🌐 Frontend Vue.js + PrimeVue

### Stack Frontend

- **Vue 3** - Composition API com `<script setup>`
- **PrimeVue 4** - UI Component Library
- **Vite** - Build tool ultra-rápido
- **Axios** - HTTP client
- **Vue Router** - Roteamento

### Funcionalidades Implementadas

#### 1. **DataTable Avançada**
```vue
<DataTable 
  :value="avisos" 
  :loading="loading"
  stripedRows
  paginator
  :rows="10"
  responsiveLayout="scroll"
/>
```

- ✅ Paginação automática
- ✅ Ordenação por colunas
- ✅ Loading state
- ✅ Empty state customizado
- ✅ Responsivo

#### 2. **Dialogs Modais**

**Criar Aviso:**
- Validação client-side
- Contador de caracteres (50 max)
- Mensagens de erro inline
- Loading no botão durante save

**Editar Aviso:**
- Título readonly (regra de negócio)
- Apenas mensagem editável
- Info message explicativa
- Validação de campo obrigatório

#### 3. **Confirmação de Exclusão**

```javascript
confirm.require({
  message: `Tem certeza que deseja excluir o aviso "${aviso.Titulo}"?`,
  header: 'Confirmação de Exclusão',
  icon: 'pi pi-exclamation-triangle',
  accept: () => deleteAviso(aviso.Id)
})
```

#### 4. **Toast Notifications**

```javascript
toast.add({
  severity: 'success',
  summary: 'Sucesso',
  detail: 'Aviso criado com sucesso!',
  life: 3000
})
```

Tipos:
- Success (verde)
- Error (vermelho)
- Info (azul)

#### 5. **Service Layer**

```javascript
// avisoService.js
export default {
  async getAllAvisos() { },
  async getAvisoById(id) { },
  async createAviso(data) { },
  async updateAviso(id, data) { },
  async deleteAviso(id) { }
}
```

**Vantagens:**
- Centraliza lógica de API
- Reutilizável
- Fácil manutenção
- Interceptors configuráveis

#### 6. **UI/UX Highlights**

- Design moderno com Aura theme
- Ícones PrimeIcons
- Tags de status coloridas (Ativo/Inativo)
- Formatação de datas pt-BR
- Tooltips em botões de ação
- Campos com validação visual (border vermelho)
- Responsivo (mobile-first)

---

## 📊 Melhorias Além do Escopo

### 1. **Frontend Completo**
Não era requisito, mas adiciona valor:
- Interface profissional
- Testes manuais facilitados
- Demonstração visual
- Portfolio piece

### 2. **Documentação Técnica Detalhada**
Este documento serve para:
- Apresentação na entrevista
- Onboarding de novos devs
- Decisões arquiteturais registradas

### 3. **Auditoria Completa**
Além de `CriadoEm` e `EditadoEm`:
- UTC para consistência global
- Atualização em todas operações
- Visível no frontend

### 4. **Validações Robustas**
- ID > 0 previne ataques
- Maxlength no título
- Whitespace validado
- Mensagens em pt-BR

### 5. **Error Handling**
- Try-catch em todos handlers
- Mensagens descritivas
- Status codes corretos (200, 201, 204, 400, 404, 500)
- Toast notifications no frontend

### 6. **Code Quality**
- Sem comentários desnecessários
- Nomes descritivos
- SOLID principles
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)

---

## 🚀 Como Executar

### Backend (.NET API)

```bash
# Navegar para a solução
cd C:\Users\thale\source\repos\BasicoDotNet

# Restaurar pacotes
dotnet restore

# Executar API
cd 1-Presentation\Bernhoeft.GRT.Teste.Api
dotnet run

# API disponível em: http://localhost:5000
# Swagger em: http://localhost:5000/swagger
```

### Frontend (Vue.js)

```bash
# Navegar para o frontend
cd 5-Web\avisos-frontend

# Instalar dependências
npm install

# Executar dev server
npm run dev

# Frontend disponível em: http://localhost:3000
```

---

## 📈 Métricas do Projeto

| Métrica | Valor |
|---------|-------|
| Endpoints criados | 5 |
| Handlers implementados | 5 |
| Validators criados | 4 |
| Camadas arquiteturais | 5 |
| Padrões aplicados | 7+ |
| Linhas de código (Backend) | ~1500 |
| Linhas de código (Frontend) | ~600 |
| Tempo estimado | 6-8 horas |

---

## 🎓 Conceitos Aplicados

### **Arquitetura**
- Clean Architecture
- DDD (Domain-Driven Design)
- Layered Architecture
- Separation of Concerns

### **Patterns**
- CQRS (Command Query Responsibility Segregation)
- Repository Pattern
- Mediator Pattern (MediatR)
- Dependency Injection
- Unit of Work (via DbContext)

### **Princípios SOLID**
- **S**ingle Responsibility
- **O**pen/Closed
- **L**iskov Substitution
- **I**nterface Segregation
- **D**ependency Inversion

### **Práticas**
- Code First (EF Core)
- API Versioning
- Soft Delete
- Audit Trail
- Input Validation
- Error Handling
- Async/Await
- CancellationTokens

---

## 🔐 Segurança

### Implementado
- ✅ Validação de entrada (FluentValidation)
- ✅ IDs positivos apenas
- ✅ Tamanhos máximos de campos
- ✅ Soft delete (preserva dados)

### Recomendado para Produção
- Authentication (JWT)
- Authorization (Policies)
- Rate Limiting
- CORS configurado corretamente
- HTTPS obrigatório
- Logging (Serilog)
- Health Checks
- API Gateway

---

## 📝 Próximos Passos (Backlog)

Se fosse evoluir o projeto:

1. **Funcionalidades**
   - Restaurar avisos deletados
   - Histórico de alterações (Event Sourcing)
   - Agendamento de avisos
   - Notificações push
   - Categorização de avisos

2. **Técnico**
   - Migrar InMemory → SQL Server
   - Implementar cache (Redis)
   - Adicionar logs estruturados (Serilog)
   - CI/CD pipeline
   - Docker containers
   - Kubernetes deployment

3. **Observabilidade**
   - Application Insights
   - Distributed tracing (OpenTelemetry)
   - Metrics (Prometheus)
   - Dashboards (Grafana)

---

## 💡 Decisões que Demonstram Senioridade

### 1. **Pensamento em Escalabilidade**
- CQRS permite escalar leitura e escrita independentemente
- Repository abstrai persistência
- Async/await em todas operações I/O

### 2. **Manutenibilidade**
- Código auto-documentado
- Separação clara de responsabilidades
- Arquitetura facilita evolução

### 3. **Performance**
- NoTracking em queries
- Paginação no DataTable
- Lazy loading de dependências

### 4. **Experiência do Desenvolvedor**
- Swagger para documentação
- Mensagens de erro claras
- Validações em português

### 5. **Experiência do Usuário**
- Interface intuitiva
- Feedback visual (toasts, loading)
- Confirmações antes de ações destrutivas

---

## 🎯 Conclusão

Este projeto demonstra conhecimento profundo em:

✅ **Arquitetura de Software** - Clean Architecture, DDD, CQRS  
✅ **Padrões de Design** - Repository, Mediator, DI  
✅ **Boas Práticas** - SOLID, Clean Code, DRY, KISS  
✅ **Frontend Moderno** - Vue 3, Composition API, PrimeVue  
✅ **APIs RESTful** - Versionamento, Swagger, Status Codes  
✅ **Qualidade de Código** - Validações, Error Handling, Auditoria  

O código está production-ready com espaço para evolução planejada.

---

**Desenvolvido para o Teste Técnico Bernhoeft GRT**

*Thales Augusto De Lima Dias - Desenvolvedor .NET*
