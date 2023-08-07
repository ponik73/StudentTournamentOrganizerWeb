<!-- 
  Project: Studentske turnaje
  File: MatchDetail.vue
  Created: 22.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Match detail page
 -->

 <template>
  <div v-if="!this.pageIsLoading" class="mainMatchDetail">
    <div class="headerMatchDetail">
      <!-- Header text with pen icon for match editing -->
      <DetailHeading :headingText="'Match detail'" />
      <section class="icons" v-if="canEdit()">
        <EditPen class="editPen" @click="editMatchRoute" />
      </section>
    </div>
    <body class="bodyMatchDetail">
      <section class="scoreSheet">
        <!-- Player's name and match score -->
        <section class="playersNames">
          <section class="playerName">
            <p
              v-if="match.partOneName"
              class="playerNameClickable"
              @click="openParticipantDetail(match.partOneOGID)"
            >
              {{ match.partOneName }}
            </p>
            <p v-if="!match.partOneName"><em>Unknown participant</em></p>
          </section>
          <section class="playerName">
            <p
              v-if="match.partTwoName"
              class="playerNameClickable"
              @click="openParticipantDetail(match.partTwoOGID)"
            >
              {{ match.partTwoName }}
            </p>
            <p v-if="!match.partTwoName"><em>Unknown participant</em></p>
          </section>
        </section>
        <p class="score">
          {{ this.getParticipantScore(match.partOneScore) }} :
          {{ this.getParticipantScore(match.partTwoScore) }}
        </p>
      </section>
      <!-- Match info -->
      <Info class="infos" :infos="infos" />
    </body>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import { ElMessage } from "element-plus";
import { plainToInstance } from "class-transformer";
import { EditPen } from "@element-plus/icons-vue";

// Classes
import MatchClass from "../js/classes/MatchClass";
import TournamentClass from "../js/classes/TournamentClass";
import InfoClass from "../js/classes/InfoClass";
import User from "../js/User";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import Info from "../components/Info.vue";

export default {
  components: {
    DetailHeading,
    Info,
    EditPen,
  },
  props: {
    id: { type: String, required: true },
  },
  data() {
    return {
      pageIsLoading: true,
      isTnmntLeader: false,
      match: MatchClass,
      tnmnt: TournamentClass,
      infos: Array(),
    };
  },
  methods: {
    async getMatchById() {
      // Fetching current match by passed id
      try {
        const params = new URLSearchParams({ matchID: this.id });
        const response = await axios.post(apiURL.matches.getById, params);
        this.match = plainToInstance(MatchClass, response.data);
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Fail in getting this match",
        });
      }
    },
    async checkIfUSerIsTnmntLeader() {
      // Checking if logged user is match tournament leader
      try {
        const params = new URLSearchParams({ tnmntID: this.match.tnmntID });
        const response = await axios.post(apiURL.tournaments.getById, params);
        this.tnmnt = plainToInstance(TournamentClass, response.data);
        this.isTnmntLeader = User.getUserID() === this.tnmnt.creatorID;
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Error in loading match tournament",
        });
      }
    },
    getParticipantScore(score) {
      // Returns score or ? if score was not set yet
      if (score) return score;

      return "?";
    },
    createInfos() {
      // Creates infos about match
      this.infos = this.match.transformToInfos();
      this.infos.push(new InfoClass("Tournament", this.tnmnt.tnmntName));
      this.infos.push(
        new InfoClass("Tournament game type", this.tnmnt.gameType)
      );
      this.infos.push(
        new InfoClass("Tournament creator", this.tnmnt.creatorName)
      );
    },
    editMatchRoute() {
      // Edit match redirect
      this.$router.push({
        name: "editMatch",
        query: { id: this.match.matchID },
      });
    },
    openParticipantDetail(partId) {
      // Redirect to selected participant detail
      if (this.match.isUserMatch === "1") {
        this.$router.push({
          name: "playerDetail",
          query: { id: partId },
        });
      } else {
        this.$router.push({
          name: "teamDetail",
          query: { id: partId },
        });
      }
    },
    canEdit() {
      // Only admin could edit match, and match must have both participants
      return (
        this.isTnmntLeader &&
        this.match.partOneID !== null &&
        this.match.partTwoID !== null
      );
    },
  },
  async created() {
    await this.getMatchById();
    await this.checkIfUSerIsTnmntLeader();
    this.createInfos();
    this.pageIsLoading = false;
  },
};
</script>

<style scoped>
.mainMatchDetail {
  height: 100vh;
}

.headerMatchDetail {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}

.bodyMatchDetail {
  margin-inline: 3rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3rem;
}

.scoreSheet {
  background: var(--color-secondary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 50%;
  font-family: var(--font-family-primary);
  font-size: x-large;
}

.playersNames {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
  align-items: center;
  width: 100%;
}

.playerName {
  padding-inline: 1rem;
  text-align: center;
  width: 50%;
}

.playerNameClickable {
  cursor: pointer;
  text-decoration: underline;
}

.score {
  font-weight: bold;
  font-size: xx-large;
}

.infos {
  background: gray;
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  font-family: var(--font-family-primary);
  padding-top: 3rem;
  padding-bottom: 3rem;
  padding-right: 3rem;
  font-size: large;
}

.icons {
  padding: 1rem;
}

.editPen {
  width: 2rem;
  cursor: pointer;
}
</style>