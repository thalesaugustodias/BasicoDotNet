<template>
  <div id="app">
    <router-view />
    <Toast position="top-right" />
    <ConfirmDialog />
  </div>
</template>

<script setup>
import Toast from 'primevue/toast'
import ConfirmDialog from 'primevue/confirmdialog'
</script>

<style>
#app {
  min-height: 100vh;
  position: relative;
}

/* Global animations for route transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Prevent layout shift during transitions */
.router-view-container {
  position: relative;
  min-height: 100%;
}
</style>
