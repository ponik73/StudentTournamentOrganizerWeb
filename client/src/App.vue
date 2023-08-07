<script>
import axios from "axios";
import apiURL from "./js/apiURL";
import User from "./js/User";

export default {
  watch: {
    $route(to, from) {
      const firstLoad = from.name == null ? true : false;
      if (firstLoad) this.onFirstLoad();
    },
  },
  methods: {
    async onFirstLoad() {
      const _sid = User.getSID();
      if (_sid) return;
      try {
        const response = await axios.get(apiURL.users.sessionStart);
        if (response.status != 200) return;
        User.setSID(response.data);
      } catch (error) {
        console.error(error);
      }
    },
  },
};
</script>

<template>
  <RouterView />
</template>

<style scoped>
</style>
