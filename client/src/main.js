import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

import './assets/base.css'

import axios from 'axios'
import VueAxios from 'vue-axios'

import 'reflect-metadata';

import ElementPlus, { ElMessage, ElMessageBox } from 'element-plus'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

import 'element-plus/dist/index.css'
import User from '../src/js/User'



const app = createApp(App)

app.use(router)
app.use(VueAxios, axios)
app.use(ElementPlus)
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}

let idleTimeout;
function setupTimers() {

    const idleTime = 60 * 60 * 1000;
    const reset = () => {
        clearTimeout(idleTimeout);
        idleTimeout = setTimeout(logout, idleTime);
    };
    const logout = () => {
        if (User.getUsername()) {
            ElMessageBox.alert("You have been logged out due to inactivity!", "Logged out", { type: "error", callback: () => { router.go(); } })
            User.logout()
        }
    };

    document.addEventListener("touchmove", reset, false);
    document.addEventListener("mousemove", reset, false);
    document.addEventListener("mousedown", reset, false);
    document.addEventListener("keypress", reset, false);


    idleTimeout = setTimeout(logout, idleTime);
}
setupTimers();
app.mount('#app')
