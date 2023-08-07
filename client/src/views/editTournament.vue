<!-- 
  Project: Studentske turnaje
  File: editTournament.vue
  Created: 24.11.2022
  Author: Martin Mores xmores02@stud.fit.vutbr.cz

  Description: Edit tournament info
 -->

 <template>
  <div class="mainEditT">
    <DetailHeading
      class="editTournamentHeading"
      :headingText="'Edit Tournament'"
    />
    <body class="bodyEdit">
      <form class="formEdit" method="post" @submit.prevent="editTournament">
        <!-- Formular for editing infos -->
        <div class="editInp">
          <!-- Tournament title -->
          <label>Change title:</label>
          <input type="text" v-model="formData.tnmntName" required />
        </div>
        <div class="editInp">
          <!-- Tournament game type -->
          <label>Change game type:</label>
          <select v-model="formData.gameType" required>
            <option v-for="item in gameTypesList" v-bind:key="item">
              {{ item }}
            </option>
          </select>
        </div>
        <div class="editInp">
          <!-- Tournament expected start -->
          <label>Change start:</label>
          <input type="datetime-local" v-model="formData.tnmntStart" required />
        </div>
        <div class="editInp">
          <!-- Max participants -->
          <label>Change max participants:</label>
          <input
            type="number"
            v-model="formData.maxParticipants"
            :min="2"
            required
          />
        </div>
        <div class="editInp">
          <!-- Tournament participants type -->
          <label>Change participant type:</label>
          <ElSwitch
            v-model="formData.isForTeams"
            active-value="1"
            inactive-value="0"
            active-text="Team"
            inactive-text="Solo"
            size="large"
          />
        </div>
        <div v-if="formData.isForTeams === '1'" class="editInp">
          <!-- Minimal team members per team in team tournament -->
          <label>Change minimal players per game in team:</label>
          <input
            type="number"
            v-model="formData.minPlayersPerGame"
            :min="1"
            required
          />
        </div>
        <input type="submit" value="Edit" class="detailButton" />
      </form>
    </body>
  </div>
</template>

<script>
import axios from "axios";
import { plainToInstance } from "class-transformer";
import { ElMessage, ElSwitch } from "element-plus";
import gameTypesList from "../js/gameTypesList.js";
import apiURL from "../js/apiURL";

// Components
import DetailHeading from "../components/DetailHeading.vue";

// Classes
import TournamentClass from "../js/classes/TournamentClass";

export default {
  components: {
    DetailHeading,
    ElSwitch,
  },
  props: {
    id: { type: String, required: true },
  },
  data() {
    return {
      gameTypesList: gameTypesList.gameTypes,
      tournament: TournamentClass,
      formData: {
        tnmntName: "",
        gameType: "",
        tnmntStart: "",
        maxParticipants: "",
        isForTeams: "",
        minPlayersPerGame: "",
        maxPart: "",
      },
    };
  },

  methods: {
    async editTournament() {
      // Edit tournament func, edit only variables which are different as original
      const params = new URLSearchParams();
      params.set("tnmntID", this.id);

      if (this.formData.tnmntName !== this.tournament.tnmntName) {
        params.set("tnmntName", this.formData.tnmntName);
      }

      if (this.formData.gameType !== this.tournament.gameType) {
        params.set("gameType", this.formData.gameType);
      }

      if (this.formData.tnmntStart !== this.tournament.tnmntStart) {
        params.set("tnmntStart", this.formData.tnmntStart);
      }

      if (this.formData.maxParticipants !== this.tournament.maxParticipants) {
        params.set("maxParticipants", this.formData.maxParticipants);
      }

      if (this.formData.isForTeams !== this.tournament.isForTeams) {
        params.set("isForTeams", this.formData.isForTeams);
      }

      if (
        this.formData.minPlayersPerGame !== this.tournament.minPlayersPerGame &&
        this.formData.minPlayersPerGame
      ) {
        params.set("minPlayersPerGame", this.formData.minPlayersPerGame);
      }

      try {
        await axios.post(apiURL.tournaments.update, params);
      } catch (error) {
        console.log(error);

        ElMessage({
          type: "error",
          message: "Failure in updating tournament",
        });

        return;
      }

      ElMessage({
        type: "success",
        message: "Tournament successfully updated",
      });

      this.$router.back();
    },
    async fetchData() {
      // Fetch tournament data on create
      const params = new URLSearchParams({ tnmntID: this.id });
      const response = await axios.post(apiURL.tournaments.getById, params);

      this.tournament = plainToInstance(TournamentClass, response.data);

      this.formData.tnmntName = this.tournament.tnmntName;
      this.formData.gameType = this.tournament.gameType;
      this.formData.maxParticipants = this.tournament.maxParticipants;
      this.formData.minPlayersPerGame = this.tournament.minPlayersPerGame;
      this.formData.isForTeams = this.tournament.isForTeams;
      this.formData.tnmntStart = this.tournament.tnmntStart;
    },
  },
  created() {
    this.fetchData();
  },
};
</script>

<style scoped>
.mainEditT {
  height: 97vh;
}
.editTournamentHeading {
  height: 9%;
}
.bodyEdit {
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: baseline;
  width: 100%;
  height: 80%;
}
.formEdit {
  width: 20%;
  height: 90%;
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  align-items: center;
}

.editInp {
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
.deatilButton {
  position: absolute;
  right: 0;
  bottom: 0;
}
</style>