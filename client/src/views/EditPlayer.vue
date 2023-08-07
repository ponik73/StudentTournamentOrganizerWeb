<!-- 
  Project: Studentske turnaje
  File: EditPlayer.vue
  Created: 20.11.2022
  Author: Martin Mores xmores02@stud.fit.vutbr.cz

  Description: Change players password, delete or leave his/her teams, or redirect to managing teams more particular
 -->

 <template>
  <div class="mainEditPlayer">
    <DetailHeading :headingText="'Edit player profile'" class="detailHeading" />
    <body class="bodyEditPlayer">
      <section class="usernameAndFormDetail">
        <form
          class="formEditPlayer"
          @submit.prevent="edit_player"
          method="post"
        >
          <!-- Change password form -->
          <section class="inptbx">
            <label>Old password:</label>
            <input
              class="inputBox"
              type="password"
              v-model="formData.oldPwd"
              required
              maxlength="24"
            />
          </section>
          <section class="inptbx">
            <label>New password:</label>
            <input
              class="inputBox"
              type="password"
              v-model="formData.newPwd"
              required
              maxlength="24"
            />
          </section>
          <section class="inptbx">
            <label>Confirm new password:</label>
            <input
              class="inputBox"
              type="password"
              v-model="CheckNewPwd"
              required
              maxlength="24"
            />
          </section>
          <input type="submit" value="Change password" class="detailButton" />
        </form>
      </section>
      <section class="teamsOptions">
        <!-- List of user's teams -->
        <h2 class="teamsListHeader">Your teams</h2>
        <ListReturnTeamID
          class="teamsList"
          :list="player.teamList"
          @itemForDelete="deleteTeam"
          @itemForLeave="leaveTeam"
        />

        <!-- Redirect to manage teams page -->
        <button class="detailButton" @click="manageTeamsRoute">
          Manage your teams
        </button>
      </section>
    </body>
  </div>
</template>

<script>
import axios from "axios";
import User from "../js/User";
import { plainToInstance } from "class-transformer";
import apiURL from "../js/apiURL";
import { isEmpty } from "lodash";
import MessageClass from "../js/classes/PopMessageClass";
import { ElMessageBox, ElMessage } from "element-plus";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import ListReturnTeamID from "../components/ListReturnItemId/ListReturnItem.vue";

// Classes
import PlayerClass from "../js/classes/PlayerClass";

export default {
  components: {
    DetailHeading,
    ListReturnTeamID,
    ElMessage,
    ElMessageBox,
  },

  data() {
    return {
      formData: {
        oldPwd: "",
        newPwd: "",
      },
      CheckNewPwd: "",
      player: new PlayerClass(),
      ID: undefined,
      name: undefined,
      message: new MessageClass(),
      badmessage: new MessageClass(),
    };
  },

  methods: {
    async edit_player() {
      // Change password function
      if (this.formData.newPwd !== this.CheckNewPwd) {
        this.formData.oldPwd = "";
        this.formData.newPwd = "";
        this.CheckNewPwd = "";
        ElMessageBox.alert("Passwords must match !", "Password change fail", {
          showClose: false,
          confirmButtonText: "OK",
          type: "error",
        });
      } else {
        try {
          const params = new URLSearchParams();
          params.set("userID", this.ID);
          if (!isEmpty(this.formData.oldPwd))
            params.set("oldPwd", this.formData.oldPwd);
          if (!isEmpty(this.formData.newPwd))
            params.set("newPwd", this.formData.newPwd);
          const response = await axios.post(apiURL.users.update, params);
          this.formData.oldPwd = "";
          this.formData.newPwd = "";
          this.CheckNewPwd = "";
          ElMessage({
            type: "success",
            message: "Password changed",
          });
        } catch (error) {
          ElMessageBox.alert("Wrong password!", "Password change fail", {
            showClose: false,
            confirmButtonText: "OK",
            type: "error",
          });
          this.badmessage.toggleShow();
          this.badmessage.header = "Error";
          this.badmessage.body = "wrong password";
          console.log(error);
        }
      }
    },
    async fetchData() {
      // Fetching user's data
      this.ID = User.getUserID();
      this.name = User.getUsername();

      const params = new URLSearchParams({ id: this.ID });
      const response = await axios.post(apiURL.users.getById, params);
      this.player = plainToInstance(PlayerClass, response.data);
      this.player.setTeamList();
    },
    manageTeamsRoute() {
      // Redirect to manage teams page
      this.$router.push({
        name: "myTeams",
      });
    },
    deleteTeam(_item) {
      // Deletes team after confirmation
      ElMessageBox.confirm(
        'Do you really want to delete team "' + _item.teamName + '"?',
        "Delete confirmation",
        {
          confirmButtonText: "YES",
          cancelButtonText: "NO",
          type: "warning",
        }
      ).then(() => {
        this.player.teamList = this.player.teamList.filter(function (item) {
          return item.teamID !== _item.teamID;
        });

        const params = new URLSearchParams({ id: _item.teamID });

        try {
          axios.post(apiURL.teams.remove, params);
        } catch (error) {
          ElMessageBox.alert("Fail in leaving team :(", "Leave team", {
            showClose: false,
            confirmButtonText: "OK",
            type: "error",
          });
        }
      });
    },
    leaveTeam(_item) {
      // User leaves team where is not leader
      ElMessageBox.confirm(
        'Do you really want to leave team "' + _item.teamName + '"?',
        "Leave confirmation",
        {
          confirmButtonText: "YES",
          cancelButtonText: "NO",
          type: "warning",
        }
      ).then(() => {
        this.player.teamList = this.player.teamList.filter(function (item) {
          return item.teamID !== _item.teamID;
        });

        const params = new URLSearchParams({
          userID: User.getUserID(),
          teamID: _item.teamID,
        });

        try {
          axios.post(apiURL.teams.removeMember, params);
        } catch (error) {
          ElMessageBox.alert("Fail in leaving team :(", "Leave team", {
            showClose: false,
            confirmButtonText: "OK",
            type: "error",
          });
          return;
        }

        ElMessage({
          type: "success",
          message: "You left team",
        });
      });
    },
  },
  created() {
    this.fetchData();
  },
};
</script>

<style scoped>
label {
  font-family: var(--font-family-primary);
  font-size: large;
}

input {
  font-family: var(--font-family-primary);
  font-size: large;
}

.mainEditPlayer {
  height: 94vh;
}

.detailHeading {
  height: 11%;
}

.bodyEditPlayer {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
  height: 89%;
  margin-inline: 3rem;
}

.formEditPlayer {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 2rem;
  gap: 1rem;
  background-color: var(--color-secondary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
}

.inptbx {
  display: flex;
  flex-direction: column;
}

.inputBox {
  width: 15rem;
}

.teamsList {
  height: 80%;
  width: 25rem;
}

.teamsOptions {
  background: var(--color-secondary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  padding: 1rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
</style>