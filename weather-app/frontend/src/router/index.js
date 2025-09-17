import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import SearchView from '../views/SearchView.vue'
import ForecastView from '../views/ForecastView.vue'
import FavoritesView from '../views/FavoritesView.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomeView,
    meta: {
      title: 'WeatherVue - Current Weather'
    }
  },
  {
    path: '/search',
    name: 'Search',
    component: SearchView,
    meta: {
      title: 'Search Locations - WeatherVue'
    }
  },
  {
    path: '/forecast',
    name: 'Forecast',
    component: ForecastView,
    meta: {
      title: 'Weather Forecast - WeatherVue'
    }
  },
  {
    path: '/favorites',
    name: 'Favorites',
    component: FavoritesView,
    meta: {
      title: 'Favorite Locations - WeatherVue'
    }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Update page title on route change
router.beforeEach((to, from, next) => {
  document.title = to.meta.title || 'WeatherVue'
  next()
})

export default router
