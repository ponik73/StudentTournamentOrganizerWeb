<!-- 
  Project: Studentske turnaje
  File: Login.vue
  Created: 5.11.2022
  Author: Martin Mores xmores02@stud.fit.vutbr.cz

  Description: Login user page
 -->

 <template>
  <div class="mainL">
    <DetailHeading :headingText="'Login'" />
    <section class="bodyClass">
      <!-- User's username and password formular -->
      <form class="formClass" @submit.prevent="login" method="post">
        <section class="LogBox">
          <!-- Username -->
          <label for="username">Username:</label>
          <input
            class="inputBox"
            type="text"
            id="username"
            v-model="formData.username"
            required
            maxlength="20"
          />
        </section>
        <section class="LogBox">
          <!-- Password -->
          <label for="pwd">Password:</label>
          <input
            class="inputBox"
            type="password"
            id="pwd"
            v-model="formData.pwd"
            required
            maxlength="24"
          />
        </section>
        <!-- Login button -->
        <input class="detailButton" type="submit" value="Login" />
      </form>
    </section>
  </div>
</template>

<script>
import axios from "axios";
import { ElMessage, ElMessageBox } from "element-plus";
import IconArrowBack from "../assets/icons/IconArrowBack.vue";
import apiURL from "../js/apiURL";
import User from "../js/User";

// Components
import PopMessage from "../components/PopMessage.vue";
import DetailHeading from "../components/DetailHeading.vue";

export default {
  components: { DetailHeading, IconArrowBack, PopMessage },
  data() {
    return {
      formData: {
        username: "",
        pwd: "",
      },
    };
  },
  methods: {
    async login() {
      // Asynchronous login, with validation for non empty inputs
      if (this.formData.username == "" || this.formData.pwd == "") {
        ElMessageBox.alert(
          "Username and password can not be empty",
          "Unsuccessful login",
          {
            confirmButtonText: "OK",
            type: "error",
          }
        );
        return;
      } else {
        try {
          const params = new URLSearchParams({
            username: this.formData.username,
            pwd: this.formData.pwd,
            SID: User.getSID(),
          });
          const response = await axios.post(apiURL.users.login, params);
          if (response.status != 200) throw new error();
          User.setUsername(response.data.username);
          User.setUserID(response.data.userID);
          await this.redirectAfterGoodLog();
          ElMessage({
            type: "success",
            message: "Welcome!",
          });
        } catch (error) {
          ElMessageBox.alert(
            "Wrong username or password",
            "Unsuccessful login",
            {
              confirmButtonText: "OK",
              type: "error",
            }
          );
        }
      }
    },

    async redirectAfterGoodLog() {
      // After successfull login, redirect user to the home page
      await new Promise((resolve) => setTimeout(resolve, 500));
      this.$router.push({ name: "home" });
    },
  },
};
</script>

<style scoped>
.bodyClass {
  padding-top: 5rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  align-content: center;
}

.formClass {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  background-color: var(--color-secondary);
  padding: 3rem;
  border-style: solid;
  border-color: var(--color-stroke);
  border-width: 2px;
  border-radius: 15px;
  width: 30%;
}

label {
  color: white;
  font-size: xx-large;
  font-family: var(--font-family-primary);
}

input {
  font-size: x-large;
  font-family: var(--font-family-primary);
}

.LogBox {
  display: flex;
  flex-direction: column;
}

.inputBox {
  width: 100%;
}
.mainL {
  height: 97vh;
  width: 97vw;
}
</style>