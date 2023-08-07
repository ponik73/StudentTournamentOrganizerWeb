<!-- 
  Project: Studentske turnaje
  File: Register.vue
  Created: 5.11.2022
  Author: Martin Mores xmores02@stud.fit.vutbr.cz

  Description: Register new user page
 -->

 <template>
  <div class="mainR">
    <DetailHeading :headingText="'Register new user'" />
    <section class="bodyClass">
      <!-- Register formular -->
      <form class="formClass" @submit.prevent="pwdCheckFun" method="post">
        <section class="RegBoxU">
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
        <section class="RegBoxU">
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
        <section class="RegBoxU">
          <!-- Password for confirmation -->
          <label for="passwordCheck">Confirm password:</label>
          <input
            class="inputBox"
            type="password"
            id="passwordCheck"
            v-model="formData.passwordCheck"
            required
            maxlength="24"
          />
        </section>

        <!-- Register button -->
        <input class="detailButton" type="submit" value="Register" />
      </form>
    </section>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import User from "../js/User";
import { ElMessage } from "element-plus";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import PopMessage from "../components/PopMessage.vue";
import InfoText from "../components/InfoTextWithLowOpacityComponent.vue";

// Classes
import MessageClass from "../js/classes/PopMessageClass";

export default {
  components: { DetailHeading, PopMessage, InfoText },
  data() {
    return {
      formData: {
        username: "",
        pwd: "",
        passwordCheck: "",
      },
      message: new MessageClass(),
    };
  },
  methods: {
    async pwdCheckFun() {
      // Checks for password if they are valid
      if (this.formData.pwd !== this.formData.passwordCheck) {
        ElMessage({
          type: "error",
          message: "Passwords are not same",
        });

        return;
      }

      const params = new URLSearchParams({
        username: this.formData.username,
        pwd: this.formData.pwd,
        passwordCheck: this.formData / passwordCheck,
        SID: User.getSID(),
      });

      try {
        const response = await axios.post(apiURL.users.register, params);
        if (response.status != 200) return;

        User.setUsername(response.data.username);
        User.setUserID(response.data.userID);

        await this.redirectAfterGoodReg();

        ElMessage({
          type: "success",
          message: "Welcome!",
        });
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Username is already taken",
        });
      }
    },

    async redirectAfterGoodReg() {
      // Redirect user to the home page after success registration
      this.message.toggleShow();
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

.inputBox {
  width: 100%;
}

.RegBoxU {
  display: flex;
  flex-direction: column;
}
.mainR {
  height: 97vh;
  width: 97vw;
}
</style>
