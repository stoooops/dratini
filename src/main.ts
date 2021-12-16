import { createApp } from "vue";
import App from "./App.vue";

import router from "./router";
import PrimeVue from "primevue/config";
import Dropdown from "primevue/dropdown";

import "primevue/resources/themes/saga-blue/theme.css"; //theme
import "primevue/resources/primevue.min.css"; //core css
import "primeicons/primeicons.css"; //icons

const app = createApp(App);

app.use(router);

app.use(PrimeVue);
app.component("Dropdown", Dropdown);

app.mount("#app");
