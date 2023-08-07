<!-- 
  Project: Studentske turnaje
  File: PlayerDetail.vue
  Created: 1.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Player detail match
 -->

 <template>
  <div class="playerDetail">
    <DetailHeading :headingText="'Player detail'" class="detailHeading" />
    <body class="bodyPlayerDetail">
      <div class="infoAndListTeams">
        <section>
          <!-- Basic infos about player with statistics if user played any match or tournament -->
          <Info class="infoDetail" :infos="infos" />
          <div class="btnDivPlayerDetail">
            <!-- Buttons for removing user or setting user as admin, only admins have visible this button and only on users which are not admins yet -->
            <label v-if="isRemove" class="detailButton" @click="removePlayer()"
              >Remove</label
            >
            <label v-if="this.isAdmin" class="detailButton" @click="setAdmin()"
              >Set as admin</label
            >
          </div>
        </section>
        <section v-show="player.teamList.length">
          <!-- List of players teams -->
          <h2>Player's teams</h2>
          <ContentBoxList
            class="teamsList"
            :header="'Teams'"
            :list="player.teamList"
            :showDetail="true"
          />
        </section>
      </div>
    </body>

    <Teleport to="body">
      <!-- Shows pop message with brief info about players remove -->
      <PopMessage
        :show="message.show"
        :header="message.header"
        :body="message.body"
        :warning="message.warning"
        @close="redirectAfterRemoval()"
      >
      </PopMessage>
    </Teleport>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import IconArrowBack from "../assets/icons/IconArrowBack.vue";
import { plainToInstance } from "class-transformer";
import User from "../js/User";
import { ElMessage } from "element-plus";

// Components
import Info from "../components/Info.vue";
import DetailHeading from "../components/DetailHeading.vue";
import PopMessage from "../components/PopMessage.vue";
import ContentBoxList from "../components/ContentBoxList.vue";

// Clases
import PlayerClass from "../js/classes/PlayerClass";
import MessageClass from "../js/classes/PopMessageClass";

export default {
  components: {
    Info,
    IconArrowBack,
    DetailHeading,
    PopMessage,
    ContentBoxList,
  },
  data() {
    return {
      player: new PlayerClass(),
      infos: Array(),
      isAdmin: false,
      showModal: false,
      message: new MessageClass(),
      removeSuccess: Boolean(),
      adminSetSuccess: Boolean(),
      isRemove: false,
    };
  },
  props: {
    id: { type: String, required: true },
  },
  methods: {
    async fetchData() {
      // Fetch user by id from url query
      try {
        const params = new URLSearchParams({ id: this.id });
        const response = await axios.post(apiURL.users.getById, params);
        this.player = plainToInstance(PlayerClass, response.data);
        if (this.player.userID != this.id) {
          this.message.toggleShow();
          this.message.warning = true;
          this.message.header = "Error";
          this.message.body =
            "Player not found. You will be redirected to home page.";
          this.removeSuccess = true;
          return;
        }
        this.setOtherPlayerData();
        this.checkAdmin();
        this.checkRemove();
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Player not found",
        });
      }
    },
    async removePlayerRequest() {
      // Remove player on button click
      try {
        const params = new URLSearchParams({ id: this.id });
        const response = await axios.post(apiURL.users.remove, params);
        if (response.status != 200) return false;
        return true;
      } catch (error) {
        console.error(error);
        return false;
      }
    },
    async setAsAdminRequest() {
      // Sets player as admin
      try {
        const params = new URLSearchParams({
          SID: User.getSID(),
          userID: this.id,
        });
        const response = await axios.post(apiURL.users.setAsAdmin, params);
        console.log(response.data);
        if (response.status != 200) return false;
        return true;
      } catch (error) {
        console.error(error);
        return false;
      }
    },
    async redirectAfterRemoval() {
      // Redirect user back to home page after removing user
      this.message.toggleShow();
      if (this.removeSuccess) {
        await new Promise((resolve) => setTimeout(resolve, 500));
        this.$router.replace({ name: "home" });
      }
    },
    setOtherPlayerData() {
      // Sets player's infos with statistics if they are available
      this.infos = this.player.TransformToInfos();

      // Sets list of player's teams
      this.player.setTeamList();
    },
    removePlayer() {
      // Remove player and show pop up message with brief info about successness
      this.removeSuccess = this.removePlayerRequest();
      if (this.removeSuccess) {
        this.message.header = "Player removed";
        this.message.body = `Player ${this.player.username} has been removed successfuly! You will be redirected to home page.`;
      } else {
        this.message.warning = true;
        this.message.header = "Error";
        this.message.body = "Error occured during removal. Try again.";
      }
      this.message.toggleShow();
    },
    setAdmin() {
      // Sets user as admin
      this.adminSetSuccess = this.setAsAdminRequest();
      if (this.adminSetSuccess) {
        this.message.header = "Player set as admin";
        this.message.body = `Player ${this.player.username} has been set as admin successfuly!`;
      } else {
        this.message.warning = true;
        this.message.header = "Error";
        this.message.body =
          "Error occured during setting player as admin. Try again.";
      }
      this.message.toggleShow();
    },
    async checkAdmin() {
      // Checks if user is admin
      try {
        const params = new URLSearchParams({ SID: User.getSID() });
        const response = await axios.post(apiURL.users.isAdmin, params);
        if (response.data == true && this.player.isAdmin == false)
          this.isAdmin = true;
        console.log(response.data);
      } catch (error) {
        console.log(error);
      }
    },
    async checkRemove() {
      // Sets if current user could remove player
      const params = new URLSearchParams({ SID: User.getSID() });
      const response = await axios.post(apiURL.users.isAdmin, params);
      if (response.data == true || User.getUsername() == this.player.username)
        this.isRemove = true;
    },
  },
  created() {
    this.fetchData();
  },
};
</script>

<style  scoped>
.playerDetail {
  height: 99vh;
}
.detailHeading {
  height: 11%;
}
.bodyPlayerDetail {
  display: flex;
  flex-direction: row;
  justify-content: start;
  align-items: baseline;
}

.btnDivPlayerDetail {
  margin-top: 3rem;
  padding-left: 2.5rem;
  justify-content: flex-start;
}

.teamsList {
  margin-right: 10rem;
  width: 25rem;
  height: 25rem;
}

.infoAndListTeams {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  width: 100%;
}
</style>