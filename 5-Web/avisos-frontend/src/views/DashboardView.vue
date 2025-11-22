<template>
  <div>
    <div class="page-header">
      <h1 class="page-title">Dashboard</h1>
      <p class="page-description">Visão geral do sistema de gerenciamento de avisos</p>
    </div>

    <div class="stats-grid">
      <div class="stat-card blue">
        <div class="stat-icon" style="background: #dbeafe; color: #1e40af;">
          <i class="pi pi-list"></i>
        </div>
        <div class="stat-label">Total de Avisos</div>
        <div class="stat-value">{{ totalAvisos }}</div>
        <div class="stat-description">Avisos cadastrados</div>
      </div>

      <div class="stat-card green">
        <div class="stat-icon" style="background: #d1fae5; color: #065f46;">
          <i class="pi pi-check-circle"></i>
        </div>
        <div class="stat-label">Avisos Ativos</div>
        <div class="stat-value">{{ avisosAtivos }}</div>
        <div class="stat-description">Publicados no sistema</div>
      </div>

      <div class="stat-card orange">
        <div class="stat-icon" style="background: #fed7aa; color: #9a3412;">
          <i class="pi pi-times-circle"></i>
        </div>
        <div class="stat-label">Avisos Inativos</div>
        <div class="stat-value">{{ avisosInativos }}</div>
        <div class="stat-description">Não publicados</div>
      </div>

      <div class="stat-card purple">
        <div class="stat-icon" style="background: #e9d5ff; color: #6b21a8;">
          <i class="pi pi-calendar"></i>
        </div>
        <div class="stat-label">Criados Hoje</div>
        <div class="stat-value">{{ avisosHoje }}</div>
        <div class="stat-description">Avisos de hoje</div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <div>
          <h2 class="card-title">Últimos Avisos</h2>
          <p class="card-subtitle">Avisos criados recentemente</p>
        </div>
        <Button label="Ver Todos" icon="pi pi-arrow-right" iconPos="right" @click="$router.push('/avisos')" text />
      </div>

      <DataTable :value="ultimosAvisos" :loading="loading" stripedRows responsiveLayout="scroll">
        <template #empty>
          <div style="text-align: center; padding: 3rem 0;">
            <i class="pi pi-inbox" style="font-size: 4rem; color: var(--text-tertiary); margin-bottom: 1rem;"></i>
            <p style="color: var(--text-secondary); font-size: 1.125rem;">Nenhum aviso encontrado</p>
            <p style="color: var(--text-tertiary); font-size: 0.875rem;">Crie seu primeiro aviso para começar</p>
          </div>
        </template>

        <Column field="Id" header="ID" style="width: 80px;">
          <template #body="{ data }">
            <span style="font-weight: 600; color: var(--primary-color);">#{{ data.Id }}</span>
          </template>
        </Column>
        
        <Column field="Titulo" header="Título">
          <template #body="{ data }">
            <span style="font-weight: 500;">{{ data.Titulo }}</span>
          </template>
        </Column>
        
        <Column field="Mensagem" header="Mensagem">
          <template #body="{ data }">
            <span style="color: var(--text-secondary);">{{ truncate(data.Mensagem, 60) }}</span>
          </template>
        </Column>
        
        <Column field="Ativo" header="Status" style="width: 120px;">
          <template #body="{ data }">
            <Tag :value="data.Ativo ? 'Ativo' : 'Inativo'" :severity="data.Ativo ? 'success' : 'danger'" />
          </template>
        </Column>
        
        <Column field="CriadoEm" header="Data" style="width: 180px;">
          <template #body="{ data }">
            <div>
              <div style="font-size: 0.875rem; font-weight: 500;">{{ formatDate(data.CriadoEm) }}</div>
              <div style="font-size: 0.75rem; color: var(--text-tertiary);">{{ formatTime(data.CriadoEm) }}</div>
            </div>
          </template>
        </Column>
      </DataTable>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Tag from 'primevue/tag'
import avisoService from '@/services/avisoService'

const router = useRouter()
const toast = useToast()

const avisos = ref([])
const loading = ref(false)

const totalAvisos = computed(() => avisos.value.length)
const avisosAtivos = computed(() => avisos.value.filter(a => a.Ativo).length)
const avisosInativos = computed(() => avisos.value.filter(a => !a.Ativo).length)
const avisosHoje = computed(() => {
  const hoje = new Date().toDateString()
  return avisos.value.filter(a => new Date(a.CriadoEm).toDateString() === hoje).length
})

const ultimosAvisos = computed(() => {
  return [...avisos.value].sort((a, b) => new Date(b.CriadoEm) - new Date(a.CriadoEm)).slice(0, 10)
})

onMounted(() => {
  loadAvisos()
})

async function loadAvisos() {
  loading.value = true
  try {
    const response = await avisoService.getAllAvisos()
    avisos.value = response.Dados || []
  } catch (error) {
    console.error('Erro ao carregar avisos:', error)
    toast.add({ severity: 'error', summary: 'Erro', detail: 'Falha ao carregar dados', life: 3000 })
  } finally {
    loading.value = false
  }
}

function formatDate(dateString) {
  return new Date(dateString).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

function formatTime(dateString) {
  return new Date(dateString).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
}

function truncate(text, length) {
  return text.length > length ? text.substring(0, length) + '...' : text
}
</script>
