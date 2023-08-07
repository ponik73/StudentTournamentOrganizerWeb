<!-- 
  Project: Studentske turnaje
  File: CreateTournament.vue
  Created: 19.11.2022
  Author: Martin Mores xmores02@stud.fit.vutbr.cz

  Description: Create tournament page
 -->

 <template>
  <div class="CreateTournament">
    <DetailHeading
      class="CreateTournamentHeading"
      :headingText="'Create Tournament'"
    />
    <body class="bodyCreateTournament">
      <form
        class="formCreateTournament"
        @submit.prevent="createTournament"
        method="post"
      >
      <!-- Formular for tournament info -->
        <div class="ho">
          <!-- Tournament title -->
          <label>Title:</label>
          <input type="text" v-model="formData.tnmntName" required />
        </div>
        <section class="ho">
          <!-- Expected tournament start -->
          <label>Expected start:</label>
          <input type="datetime-local" v-model="formData.tnmntStart" required />
        </section>
        <div class="ho">
          <!-- Tournament game type -->
          <label>Game type:</label>
          <select v-model="formData.gameType" required>
            <option v-for="item in gameTypesList" v-bind:key="item">
              {{ item }}
            </option>
          </select>
        </div>
        <div class="ho">
          <!-- Max participants -->
          <label>Max Participants:</label>
          <input type="number" min="2" v-model="formData.maxParticipants" />
        </div>
        <div class="ho">
          <!-- Set participants type -->
          <label>Participant type:</label>
          <ElSwitch
            v-model="formData.isForTeams"
            active-value="1"
            inactive-value="0"
            active-text="Team"
            inactive-text="Solo"
            size="large"
          />
        </div>
        <div v-if="formData.isForTeams === '1'" class="ho">
          <!-- Minimal players per game, visibble only when team tournament is selected -->
          <label>Minimal players per game in team:</label>
          <input type="number" min="1" v-model="formData.minPlayersPerGame" />
        </div>
        <input type="submit" value="Create" class="detailButton" />
      </form>
    </body>
    <div class="podpis">
      After creating new tournament wait for verticifation by admin
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { ref } from "vue";
import { ElMessage, ElMessageBox, ElSwitch } from "element-plus";
import User from "../js/User";
import gameTypesList from "../js/gameTypesList.js";
import apiURL from "../js/apiURL";
import ErrorMessageConverter from "../js/ErrorMessageConverter";

// Components
import ContentBoxList from "../components/ContentBoxList.vue";
import DetailHeading from "../components/DetailHeading.vue";
import InputBox from "../components/InputBox.vue";

const hide = ref();

export default {
  components: { DetailHeading, ContentBoxList, InputBox, ElSwitch },

  data() {
    return {
      gameTypesList: gameTypesList.gameTypes,
      tnmntID: null,
      formData: {
        tnmntName: "",
        gameType: "",
        tnmntStart: "",
        minPlayersPerGame: "1",
        maxParticipants: "8",
        isForTeams: "0",
        SID: User.getSID(),
      },
    };
  },
  methods: {
    async createTournament() {
      // Creates tournament, inform user about waiting for approval and redirect user to the tournament detail
      try {
        const params = new URLSearchParams(this.formData);
        const response = await axios.post(apiURL.tournaments.create, params);
        if (response.status != 200) {
          const _errorMsg = ErrorMessageConverter.convert(response.data);
          ElMessage({ showClose: true, message: _errorMsg, type: "error" });
          return;
        }
        this.tnmntID = response.data.tnmntID;
        ElMessageBox.alert(
          `Tournament ${this.formData.tnmntName} was created successfuly! Please wait for tournament approval.`,
          "Tournament created!",
          {
            showClose: false,
            confirmButtonText: "OK",
            callback: () => {
              this.$router.replace({
                name: "tournamentDetail",
                query: { id: this.tnmntID },
              });
            },
          }
        );
      } catch (error) {
        console.error(error);
        const _errorMsg = ErrorMessageConverter.convert(error.response.data);
        ElMessage({ showClose: true, message: _errorMsg, type: "error" });
      }
    },
  },
  created() {
    var date = new Date();
    date.setHours(date.getHours() + 1);
    date.setMinutes(date.getMinutes() + 30);
    this.formData.tnmntStart = date.toISOString().slice(0, -8);
  },
};
</script>

<style scoped>
.CreateTournament {
  height: 97vh;
}
.CreateTournamentHeading {
  height: 9%;
}
.bodyCreateTournament {
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: baseline;
  width: 100%;
  height: 80%;
}
.formCreateTournament {
  width: 20%;
  height: 90%;
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  align-items: center;
}

.ho {
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  display: flex;
  flex-direction: column;
  justify-content: space-around;
  background-color: var(--color-secondary);
  padding: 1rem;
  margin-bottom: 1rem;
  width: 120%;
  height: 5rem;
}

.detailButton {
  position: absolute;
  right: 0;
  bottom: 0;
}
.podpis {
  opacity: 30%;
  text-align: center;
}
</style>