<!-- 
  Project: Studentske turnaje
  File: BracketDetaill.vue
  Created: 24.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Showing tournament matches as bracket
 -->

<template>
  <div v-if="!loading" class="mainBracketDetail">
    <DetailHeading :heading-text="'Bracket detail'" />
    <div class="bodyBracketDetail">
      <!-- Tournament basic info -->
      <Info :infos="infos" />

      <!-- Message when bracket is not generated yet -->
      <p v-if="matches.length === 0" class="noBracketMessage">
        <em>Tournament has no bracket to show yet</em>
      </p>

      <!-- Bracket component -->
      <Bracket
        v-if="matches.length > 0"
        class="bracket"
        :matches="matches"
        @selectedItem="selectedItemClick"
      />
    </div>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import { plainToInstance } from "class-transformer";
import { ElMessage } from "element-plus";
import ErrorMessageConverter from "../js/ErrorMessageConverter";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import Info from "../components/Info.vue";
import Bracket from "../components/BracketComponent.vue";

// Classes
import TournamentClass from "../js/classes/TournamentClass";
import InfoClass from "../js/classes/InfoClass";
import MatchClass from "../js/classes/MatchClass";

export default {
  components: {
    DetailHeading,
    Info,
    Bracket,
  },
  props: {
    id: { type: String, required: true },
  },
  data() {
    return {
      loading: true,
      infos: Array(),
      tournament: TournamentClass,
      matches: Array(),
    };
  },
  methods: {
    //#region Async functions for getting data
    async fetchData() {
      // Fetching tournament
      try {
        const params = new URLSearchParams({ tnmntID: this.id });
        const response = await axios.post(apiURL.tournaments.getById, params);

        this.tournament = plainToInstance(TournamentClass, response.data);
      } catch (error) {
        const errMess = ErrorMessageConverter.convert(
          error.response ? error.response.data : error
        );
        ElMessage({
          type: "error",
          message: errMess,
        });
      }

      this.setInfos();
    },
    async getMatches() {
      // Getting tournament matches by tournament id
      try {
        const params = new URLSearchParams({ tnmntID: this.id });
        const response = await axios.post(
          apiURL.matches.getTnmntMatches,
          params
        );

        response.data.forEach((element) => {
          this.matches.push(plainToInstance(MatchClass, element));
        });
      } catch (error) {
        const errMess = ErrorMessageConverter.convert(
          error.response ? error.response.data : error
        );
        ElMessage({
          type: "error",
          message: errMess,
        });
      }
    },
    //#endregion
    setInfos() {
      // Setting infos list
      this.infos.push(new InfoClass("Tournament", this.tournament.tnmntName));
      this.infos.push(
        new InfoClass("Tournament start", this.tournament.getStart())
      );
      this.infos.push(
        new InfoClass("Tournament status", this.tournament.getStatus())
      );
    },
    selectedItemClick(_item) {
      // Moving user to the match detail page
      this.$router.push({
        name: "matchDetail",
        query: { id: _item.matchID },
      });
    },
  },
  async created() {
    await this.fetchData();
    await this.getMatches();
    this.loading = false;
  },
};
</script>

<style scoped>
.mainBracketDetail {
  height: 98vh;
}

.bodyBracketDetail {
  height: 91%;
}

.bracket {
  height: 85%;
  overflow-y: scroll;
}

.noBracketMessage {
  width: 100%;
  height: 40%;
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>