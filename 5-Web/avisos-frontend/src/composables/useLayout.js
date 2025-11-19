import { computed, reactive } from 'vue'

const layoutConfig = reactive({
  darkTheme: false,
  menuMode: 'static'
})

const layoutState = reactive({
  staticMenuDesktopInactive: false,
  overlayMenuActive: false,
  staticMenuMobileActive: false,
  menuHoverActive: false,
  activeMenuItem: null,
  sidebarVisible: false
})

export function useLayout() {
  const setActiveMenuItem = (item) => {
    layoutState.activeMenuItem = item.value || item
  }

  const toggleDarkMode = () => {
    layoutConfig.darkTheme = !layoutConfig.darkTheme
    document.documentElement.classList.toggle('dark-mode')
  }

  const toggleMenu = () => {
    if (layoutConfig.menuMode === 'overlay') {
      layoutState.overlayMenuActive = !layoutState.overlayMenuActive
    }

    if (window.innerWidth > 991) {
      layoutState.staticMenuDesktopInactive = !layoutState.staticMenuDesktopInactive
    } else {
      layoutState.staticMenuMobileActive = !layoutState.staticMenuMobileActive
    }
  }

  const toggleSidebar = () => {
    layoutState.sidebarVisible = !layoutState.sidebarVisible
  }

  const isSidebarActive = computed(() => layoutState.overlayMenuActive || layoutState.staticMenuMobileActive)
  
  const isSidebarVisible = computed(() => layoutState.sidebarVisible)

  const isDarkTheme = computed(() => layoutConfig.darkTheme)

  return {
    layoutConfig,
    layoutState,
    toggleMenu,
    toggleSidebar,
    isSidebarActive,
    isSidebarVisible,
    isDarkTheme,
    setActiveMenuItem,
    toggleDarkMode
  }
}
