<template>
  <div>
    <div class="page-header">
      <h1 class="page-title">Gestão de Avisos</h1>
      <p class="page-description">Gerencie todos os avisos do sistema</p>
    </div>

    <div class="card">
      <div class="flex-between mb-lg">
        <IconField iconPosition="left" style="flex: 1; max-width: 400px;">
          <InputIcon class="pi pi-search" />
          <InputText v-model="searchTerm" placeholder="Pesquisar por título ou mensagem..." style="width: 100%;" />
        </IconField>
        
        <div class="flex gap-sm">
          <Button icon="pi pi-refresh" @click="loadAvisos" :loading="loading" severity="secondary" outlined />
          <Button label="Novo Aviso" icon="pi pi-plus" @click="router.push('/create')" />
        </div>
      </div>

      <DataTable 
        :value="filteredAvisos" 
        :loading="loading" 
        paginator 
        :rows="10" 
        stripedRows
        :rowsPerPageOptions="[5, 10, 20, 50]"
        responsiveLayout="scroll"
        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
        currentPageReportTemplate="Mostrando {first} a {last} de {totalRecords} avisos"
      >
        <template #empty>
          <div style="text-align: center; padding: 3rem 0;">
            <i class="pi pi-inbox" style="font-size: 4rem; color: var(--text-tertiary); margin-bottom: 1rem;"></i>
            <p style="color: var(--text-secondary); font-size: 1.125rem; margin-bottom: 0.5rem;">Nenhum aviso encontrado</p>
            <p style="color: var(--text-tertiary); font-size: 0.875rem;">Crie seu primeiro aviso para começar</p>
          </div>
        </template>

        <Column field="Id" header="ID" sortable style="width: 80px;">
          <template #body="{ data }">
            <span style="font-weight: 600; color: var(--primary-color);">#{{ data.Id }}</span>
          </template>
        </Column>

        <Column field="Titulo" header="Título" sortable>
          <template #body="{ data }">
            <span style="font-weight: 500;">{{ data.Titulo }}</span>
          </template>
        </Column>

        <Column field="Mensagem" header="Mensagem" sortable>
          <template #body="{ data }">
            <span style="color: var(--text-secondary);">{{ truncate(data.Mensagem, 80) }}</span>
          </template>
        </Column>

        <Column field="Ativo" header="Status" sortable style="width: 120px;">
          <template #body="{ data }">
            <Tag :value="data.Ativo ? 'Ativo' : 'Inativo'" :severity="data.Ativo ? 'success' : 'danger'" />
          </template>
        </Column>

        <Column field="CriadoEm" header="Criado em" sortable style="width: 180px;">
          <template #body="{ data }">
            <div>
              <div style="font-size: 0.875rem; font-weight: 500;">{{ formatDate(data.CriadoEm) }}</div>
              <div style="font-size: 0.75rem; color: var(--text-tertiary);">{{ formatTime(data.CriadoEm) }}</div>
            </div>
          </template>
        </Column>

        <Column header="Ações" style="width: 180px;">
          <template #body="{ data }">
            <div class="flex gap-sm">
              <Button 
                icon="pi pi-eye" 
                severity="info" 
                text 
                rounded 
                @click="viewAviso(data)" 
                v-tooltip.top="'Visualizar'"
                :disabled="isDeleting || updateLoading" 
              />
              <Button 
                icon="pi pi-pencil" 
                severity="warning" 
                text 
                rounded 
                @click="editAviso(data)" 
                v-tooltip.top="'Editar'"
                :disabled="isDeleting || updateLoading" 
              />
              <Button 
                icon="pi pi-trash" 
                severity="danger" 
                text 
                rounded 
                @click="confirmDelete(data)" 
                v-tooltip.top="'Excluir'"
                :disabled="isDeleting || updateLoading"
                :loading="isDeleting && deletingId === data.Id" 
              />
            </div>
          </template>
        </Column>
      </DataTable>
    </div>

    <Dialog v-model:visible="viewDialog" modal style="width: 600px;" :dismissableMask="true">
      <template #header>
        <div class="flex gap-sm" style="align-items: center;">
          <i class="pi pi-file" style="color: var(--primary-color); font-size: 1.5rem;"></i>
          <span style="font-weight: 700; font-size: 1.25rem;">Detalhes do Aviso</span>
        </div>
      </template>
      
      <div v-if="selectedAviso" style="display: flex; flex-direction: column; gap: 1.5rem;">
        <div>
          <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 0.5rem;">ID</div>
          <p style="font-weight: 600; color: var(--primary-color); margin: 0;">#{{ selectedAviso.Id }}</p>
        </div>
        
        <div>
          <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 0.5rem;">Título</div>
          <p style="font-weight: 500; font-size: 1.125rem; margin: 0;">{{ selectedAviso.Titulo }}</p>
        </div>
        
        <div>
          <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 0.5rem;">Mensagem</div>
          <p style="color: var(--text-primary); line-height: 1.6; margin: 0;">{{ selectedAviso.Mensagem }}</p>
        </div>
        
        <div style="display: flex; gap: 2rem;">
          <div>
            <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 0.5rem;">Status</div>
            <Tag :value="selectedAviso.Ativo ? 'Ativo' : 'Inativo'" :severity="selectedAviso.Ativo ? 'success' : 'danger'" />
          </div>
          
          <div>
            <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 0.5rem;">Criado em</div>
            <p style="color: var(--text-primary); margin: 0;">{{ formatDate(selectedAviso.CriadoEm) }} às {{ formatTime(selectedAviso.CriadoEm) }}</p>
          </div>
        </div>
      </div>
      
      <template #footer>
        <Button label="Fechar" icon="pi pi-times" @click="viewDialog = false" severity="secondary" />
      </template>
    </Dialog>

    <Dialog v-model:visible="editDialog" modal style="width: 600px;" :dismissableMask="false">
      <template #header>
        <div class="flex gap-sm" style="align-items: center;">
          <i class="pi pi-pencil" style="color: var(--primary-color); font-size: 1.5rem;"></i>
          <span style="font-weight: 700; font-size: 1.25rem;">Editar Aviso</span>
        </div>
      </template>
      
      <form @submit.prevent="updateAviso" style="display: flex; flex-direction: column; gap: 1.5rem;">
        <div class="form-group">
          <label for="edit-titulo" class="form-label">
            Título<span class="required">*</span>
          </label>
          <InputText
            id="edit-titulo"
            v-model="editForm.Titulo"
            placeholder="Digite o título do aviso"
            style="width: 100%;"
            :class="{ 'p-invalid': editErrors.Titulo }"
          />
          <small v-if="editErrors.Titulo" class="form-error">{{ editErrors.Titulo }}</small>
        </div>

        <div class="form-group">
          <label for="edit-mensagem" class="form-label">
            Mensagem<span class="required">*</span>
          </label>
          <Textarea
            id="edit-mensagem"
            v-model="editForm.Mensagem"
            rows="6"
            placeholder="Digite a mensagem do aviso"
            style="width: 100%;"
            :class="{ 'p-invalid': editErrors.Mensagem }"
          />
          <small v-if="editErrors.Mensagem" class="form-error">{{ editErrors.Mensagem }}</small>
        </div>

        <div class="form-group">
          <label class="form-label">Status</label>
          <div class="flex gap-lg">
            <div class="flex gap-sm" style="align-items: center;">
              <RadioButton v-model="editForm.Ativo" inputId="edit-ativo" :value="true" />
              <label for="edit-ativo" style="cursor: pointer; font-weight: 500;">Ativo</label>
            </div>
            <div class="flex gap-sm" style="align-items: center;">
              <RadioButton v-model="editForm.Ativo" inputId="edit-inativo" :value="false" />
              <label for="edit-inativo" style="cursor: pointer; font-weight: 500;">Inativo</label>
            </div>
          </div>
        </div>
      </form>
      
      <template #footer>
        <div class="flex gap-sm" style="justify-content: flex-end;">
          <Button label="Cancelar" icon="pi pi-times" @click="editDialog = false" severity="secondary" outlined :disabled="updateLoading" />
          <Button label="Salvar Alterações" icon="pi pi-check" @click="updateAviso" :loading="updateLoading" />
        </div>
      </template>
    </Dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import { useConfirm } from 'primevue/useconfirm'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import RadioButton from 'primevue/radiobutton'
import Tag from 'primevue/tag'
import Dialog from 'primevue/dialog'
import IconField from 'primevue/iconfield'
import InputIcon from 'primevue/inputicon'
import avisoService from '@/services/avisoService'

const router = useRouter()
const toast = useToast()
const confirm = useConfirm()

const avisos = ref([])
const loading = ref(false)
const searchTerm = ref('')
const viewDialog = ref(false)
const selectedAviso = ref(null)
const editDialog = ref(false)
const updateLoading = ref(false)
const isDeleting = ref(false)
const deletingId = ref(null)
const editForm = ref({
  Id: null,
  Titulo: '',
  Mensagem: '',
  Ativo: true
})
const editErrors = ref({
  Titulo: '',
  Mensagem: ''
})

const filteredAvisos = computed(() => {
  if (!searchTerm.value) return avisos.value
  const term = searchTerm.value.toLowerCase()
  return avisos.value.filter(a =>
    a.Titulo?.toLowerCase().includes(term) ||
    a.Mensagem?.toLowerCase().includes(term)
  )
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
    toast.add({ severity: 'error', summary: 'Erro', detail: 'Falha ao carregar avisos', life: 3000 })
  } finally {
    loading.value = false
  }
}

function viewAviso(aviso) {
  selectedAviso.value = aviso
  viewDialog.value = true
}

function editAviso(aviso) {
  editForm.value = {
    Id: aviso.Id,
    Titulo: aviso.Titulo,
    Mensagem: aviso.Mensagem,
    Ativo: aviso.Ativo
  }
  editErrors.value = { Titulo: '', Mensagem: '' }
  editDialog.value = true
}

function validateEditForm() {
  editErrors.value.Titulo = ''
  editErrors.value.Mensagem = ''
  let isValid = true

  if (!editForm.value.Titulo?.trim()) {
    editErrors.value.Titulo = 'O título é obrigatório'
    isValid = false
  } else if (editForm.value.Titulo.length < 3) {
    editErrors.value.Titulo = 'O título deve ter no mínimo 3 caracteres'
    isValid = false
  }

  if (!editForm.value.Mensagem?.trim()) {
    editErrors.value.Mensagem = 'A mensagem é obrigatória'
    isValid = false
  } else if (editForm.value.Mensagem.length < 10) {
    editErrors.value.Mensagem = 'A mensagem deve ter no mínimo 10 caracteres'
    isValid = false
  }

  return isValid
}

async function updateAviso() {
  if (!validateEditForm()) {
    toast.add({ severity: 'warn', summary: 'Atenção', detail: 'Por favor, corrija os erros no formulário', life: 3000 })
    return
  }

  updateLoading.value = true
  try {
    await avisoService.updateAviso(editForm.value.Id, {
      Id: editForm.value.Id,
      Titulo: editForm.value.Titulo,
      Mensagem: editForm.value.Mensagem,
      Ativo: editForm.value.Ativo
    })
    toast.add({ severity: 'success', summary: 'Sucesso', detail: 'Aviso atualizado com sucesso!', life: 3000 })
    editDialog.value = false
    await loadAvisos()
  } catch (error) {
    console.error('Erro ao atualizar aviso:', error)
    const errorMessage = error.response?.data?.Mensagens?.[0] || error.response?.data?.message || 'Falha ao atualizar aviso'
    toast.add({ severity: 'error', summary: 'Erro', detail: errorMessage, life: 3000 })
  } finally {
    updateLoading.value = false
  }
}

function confirmDelete(aviso) {
  if (isDeleting.value) {
    return
  }
  
  confirm.require({
    message: `Tem certeza que deseja excluir o aviso "${aviso.Titulo}"?`,
    header: 'Confirmar Exclusão',
    icon: 'pi pi-exclamation-triangle',
    rejectLabel: 'Não',
    acceptLabel: 'Sim',
    rejectClass: 'p-button-secondary p-button-outlined',
    acceptClass: 'p-button-danger',
    accept: () => {
      deleteAviso(aviso.Id)
    },
    reject: () => {
      isDeleting.value = false
    }
  })
}

async function deleteAviso(id) {
  if (isDeleting.value) return
  
  isDeleting.value = true
  deletingId.value = id
  
  // Fecha o modal de confirmação imediatamente
  confirm.close()
  
  try {
    await avisoService.deleteAviso(id)
    toast.add({ severity: 'success', summary: 'Sucesso', detail: 'Aviso excluído com sucesso!', life: 3000 })
    await loadAvisos()
  } catch (error) {
    console.error('Erro ao excluir aviso:', error)
    const errorMessage = error.response?.data?.Mensagens?.[0] || error.response?.data?.message || 'Falha ao excluir aviso'
    toast.add({ severity: 'error', summary: 'Erro', detail: errorMessage, life: 3000 })
  } finally {
    isDeleting.value = false
    deletingId.value = null
  }
}

function formatDate(dateString) {
  return new Date(dateString).toLocaleDateString('pt-BR')
}

function formatTime(dateString) {
  return new Date(dateString).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
}

function truncate(text, length) {
  return text && text.length > length ? text.substring(0, length) + '...' : text
}
</script>
