<template>
  <div>
    <div class="page-header">
      <h1 class="page-title">Novo Aviso</h1>
      <p class="page-description">Crie um novo aviso para o sistema</p>
    </div>

    <div class="grid grid-cols-3">
      <div style="grid-column: span 2 / span 2;">
        <div class="card">
          <form @submit.prevent="handleSubmit">
            <div class="form-group">
              <label for="titulo" class="form-label">
                Título<span class="required">*</span>
              </label>
              <InputText
                id="titulo"
                v-model="form.titulo"
                placeholder="Digite o título do aviso"
                style="width: 100%;"
                :class="{ 'p-invalid': errors.titulo }"
              />
              <small v-if="errors.titulo" class="form-error">{{ errors.titulo }}</small>
            </div>

            <div class="form-group">
              <label for="mensagem" class="form-label">
                Mensagem<span class="required">*</span>
              </label>
              <Textarea
                id="mensagem"
                v-model="form.mensagem"
                rows="8"
                placeholder="Digite a mensagem do aviso"
                style="width: 100%;"
                :class="{ 'p-invalid': errors.mensagem }"
              />
              <small v-if="errors.mensagem" class="form-error">{{ errors.mensagem }}</small>
            </div>

            <div class="form-group">
              <label class="form-label">Status</label>
              <div class="flex gap-lg">
                <div class="flex gap-sm" style="align-items: center;">
                  <RadioButton v-model="form.ativo" inputId="ativo" :value="true" />
                  <label for="ativo" style="cursor: pointer; font-weight: 500;">Ativo</label>
                </div>
                <div class="flex gap-sm" style="align-items: center;">
                  <RadioButton v-model="form.ativo" inputId="inativo" :value="false" />
                  <label for="inativo" style="cursor: pointer; font-weight: 500;">Inativo</label>
                </div>
              </div>
            </div>

            <div class="flex gap-sm" style="padding-top: 1rem; border-top: 1px solid var(--border-color);">
              <Button label="Salvar Aviso" icon="pi pi-check" type="submit" :loading="loading" style="flex: 1;" />
              <Button label="Cancelar" icon="pi pi-times" severity="secondary" outlined @click="handleCancel" :disabled="loading" />
            </div>
          </form>
        </div>
      </div>

      <div>
        <div class="card" style="position: sticky; top: 100px;">
          <div class="flex gap-sm" style="align-items: center; margin-bottom: 1.5rem;">
            <i class="pi pi-eye" style="color: var(--primary-color); font-size: 1.25rem;"></i>
            <h3 style="font-size: 1.125rem; font-weight: 700; margin: 0;">Preview</h3>
          </div>
          
          <div style="display: flex; flex-direction: column; gap: 1.25rem;">
            <div>
              <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 0.5rem;">Título</div>
              <div style="font-weight: 500; color: var(--text-primary);">
                {{ form.titulo || 'Título do aviso' }}
              </div>
            </div>

            <div>
              <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 0.5rem;">Mensagem</div>
              <div style="color: var(--text-secondary); font-size: 0.875rem; line-height: 1.6;">
                {{ form.mensagem || 'Mensagem do aviso aparecerá aqui...' }}
              </div>
            </div>

            <div>
              <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 0.5rem;">Status</div>
              <Tag
                :value="form.ativo ? 'Ativo' : 'Inativo'"
                :severity="form.ativo ? 'success' : 'danger'"
              />
            </div>

            <div style="padding-top: 1rem; border-top: 1px solid var(--border-color);">
              <div class="flex gap-sm" style="align-items: center; color: var(--text-tertiary); font-size: 0.875rem;">
                <i class="pi pi-info-circle"></i>
                <span>Preencha os campos para visualizar</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import Button from 'primevue/button'
import RadioButton from 'primevue/radiobutton'
import Tag from 'primevue/tag'
import avisoService from '@/services/avisoService'

const router = useRouter()
const toast = useToast()
const loading = ref(false)

const form = reactive({
  titulo: '',
  mensagem: '',
  ativo: true
})

const errors = reactive({
  titulo: '',
  mensagem: ''
})

const validateForm = () => {
  errors.titulo = ''
  errors.mensagem = ''
  let isValid = true

  if (!form.titulo.trim()) {
    errors.titulo = 'O título é obrigatório'
    isValid = false
  } else if (form.titulo.length < 3) {
    errors.titulo = 'O título deve ter no mínimo 3 caracteres'
    isValid = false
  }

  if (!form.mensagem.trim()) {
    errors.mensagem = 'A mensagem é obrigatória'
    isValid = false
  } else if (form.mensagem.length < 10) {
    errors.mensagem = 'A mensagem deve ter no mínimo 10 caracteres'
    isValid = false
  }

  return isValid
}

const handleSubmit = async () => {
  if (!validateForm()) {
    toast.add({ severity: 'warn', summary: 'Atenção', detail: 'Por favor, corrija os erros no formulário', life: 3000 })
    return
  }

  loading.value = true
  try {
    const avisoData = { Titulo: form.titulo, Mensagem: form.mensagem, Ativo: form.ativo }
    await avisoService.createAviso(avisoData)
    toast.add({ severity: 'success', summary: 'Sucesso', detail: 'Aviso criado com sucesso!', life: 3000 })
    setTimeout(() => router.push('/avisos'), 500)
  } catch (error) {
    console.error('Erro ao criar aviso:', error)
    toast.add({ severity: 'error', summary: 'Erro', detail: error.response?.data?.message || 'Falha ao criar aviso', life: 3000 })
  } finally {
    loading.value = false
  }
}

const handleCancel = () => router.push('/avisos')
</script>
