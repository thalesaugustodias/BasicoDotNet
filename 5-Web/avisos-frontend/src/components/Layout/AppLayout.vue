<template>
  <div class="app-container">
    <header class="app-header">
      <nav class="navbar">
        <div class="navbar-brand">
          <i class="pi pi-bell"></i>
          <span class="brand-title">Sistema de Avisos</span>
        </div>
        
        <div class="navbar-menu">
          <router-link to="/" class="nav-link" :class="{ active: $route.path === '/' }">
            <i class="pi pi-home"></i>
            <span>Dashboard</span>
          </router-link>
          <router-link to="/avisos" class="nav-link" :class="{ active: $route.path === '/avisos' }">
            <i class="pi pi-list"></i>
            <span>Avisos</span>
          </router-link>
          <router-link to="/create" class="nav-link" :class="{ active: $route.path === '/create' }">
            <i class="pi pi-plus-circle"></i>
            <span>Novo Aviso</span>
          </router-link>
        </div>
        
        <div class="navbar-actions">
          <Button icon="pi pi-bell" rounded text severity="secondary" badge="3" badgeSeverity="danger" />
          <Button icon="pi pi-user" rounded text severity="secondary" />
        </div>
      </nav>
    </header>

    <main class="app-main fade-in">
      <router-view />
    </main>

    <footer class="app-footer">
      <p>&copy; 2024 Sistema de Avisos - Todos os direitos reservados</p>
    </footer>

    <Toast />
    <ConfirmDialog />
  </div>
</template>

<script setup>
import Button from 'primevue/button'
import Toast from 'primevue/toast'
import ConfirmDialog from 'primevue/confirmdialog'
</script>

<style scoped>
.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 2rem;
  max-width: 1400px;
  margin: 0 auto;
  height: 70px;
}

.navbar-brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary-color);
}

.navbar-brand .pi {
  font-size: 1.75rem;
}

.brand-title {
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-light) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.navbar-menu {
  display: flex;
  gap: 0.5rem;
  flex: 1;
  justify-content: center;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  font-weight: 500;
  transition: all 0.2s ease;
  text-decoration: none;
}

.nav-link:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.nav-link.active {
  background: var(--primary-color);
  color: white;
  box-shadow: var(--shadow-md);
}

.nav-link .pi {
  font-size: 1.1rem;
}

.navbar-actions {
  display: flex;
  gap: 0.5rem;
}

@media (max-width: 768px) {
  .navbar {
    flex-direction: column;
    height: auto;
    gap: 1rem;
  }
  
  .navbar-menu {
    width: 100%;
    justify-content: space-around;
  }
  
  .nav-link span {
    display: none;
  }
}
</style>
