# Sistema de Avisos - Frontend

Frontend em Vue.js 3 com PrimeVue para o Sistema de Gestão de Avisos.

## 🚀 Tecnologias

- Vue.js 3 (Composition API)
- Vite
- PrimeVue 4
- Axios
- Vue Router

## 📦 Instalação

```bash
npm install
```

## 🏃 Execução

### Desenvolvimento
```bash
npm run dev
```

O frontend estará disponível em http://localhost:3000

### Build de Produção
```bash
npm run build
```

### Preview da Build
```bash
npm run preview
```

## ⚙️ Configuração

Configure a URL da API no arquivo `.env`:

```env
VITE_API_BASE_URL=http://localhost:5000
```

## 🎨 Funcionalidades

- ✅ Listagem de avisos ativos com paginação
- ✅ Criação de novos avisos
- ✅ Edição de mensagem (conforme regra de negócio)
- ✅ Exclusão com soft delete
- ✅ Visualização de dados de auditoria (criado em, editado em)
- ✅ Interface responsiva
- ✅ Validações de formulário
- ✅ Notificações toast
- ✅ Confirmação de exclusão

## 📁 Estrutura

```
src/
├── assets/         # Arquivos estáticos e CSS
├── services/       # Serviços de API
├── views/          # Componentes de página
├── App.vue         # Componente raiz
└── main.js         # Ponto de entrada
```
