import './assets/main.css'

import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import PrimeVue from 'primevue/config'
import Aura from '@primevue/themes/aura'
import ToastService from 'primevue/toastservice'
import ConfirmationService from 'primevue/confirmationservice'
import Tooltip from 'primevue/tooltip'
import Ripple from 'primevue/ripple'

import App from './App.vue'
import AppLayout from './components/Layout/AppLayout.vue'
import DashboardView from './views/DashboardView.vue'
import AvisosView from './views/AvisosView.vue'
import CreateAvisoView from './views/CreateAvisoView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: AppLayout,
      children: [
        {
          path: '',
          name: 'dashboard',
          component: DashboardView
        },
        {
          path: 'avisos',
          name: 'avisos',
          component: AvisosView
        },
        {
          path: 'create',
          name: 'create',
          component: CreateAvisoView
        }
      ]
    }
  ]
})

const app = createApp(App)

app.use(router)
app.use(PrimeVue, {
  theme: {
    preset: Aura,
    options: {
      prefix: 'p',
      darkModeSelector: false,
      cssLayer: false
    }
  },
  ripple: true
})
app.use(ToastService)
app.use(ConfirmationService)

app.directive('tooltip', Tooltip)
app.directive('ripple', Ripple)

app.mount('#app')
