<!-- 
  Project: Studentske turnaje
  File: DetailHeading.vue
  Created: 6.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Header with title and with redirecting back icon, also showing logged user
 -->

 <template>
  <div id="divHeading">
    <IconArrowBack />
    <h2 id="headingText">{{headingText}}</h2>
    <!-- Icon and user's username are showed only if page is showing to the registered user -->
    <UsrIcon v-if="username" class="userIcon"/>
    <p v-if="username"><em>{{ username }}</em></p>
  </div>
</template>

<script>
import IconArrowBack from '../assets/icons/IconArrowBack.vue';
import { User as UsrIcon } from "@element-plus/icons-vue";
import User from "../js/User";

export default {
    components: 
    { 
      IconArrowBack, 
      UsrIcon 
    },
    props:
    {
        headingText: {typeof: String, required: true}
    },
    data() 
    {
      return {
        username: ''
      }
    },
    created() 
    {
      this.username = User.getUsername();
    }
};
</script>

<style scoped>

#divHeading{
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
}

#headingText{
  margin: 1rem;
}

.userIcon {
  margin-left: 2rem;
  margin-right: 1rem;
  width: 30px;
}

</style>