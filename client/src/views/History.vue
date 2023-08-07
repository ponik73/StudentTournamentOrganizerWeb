<!-- 
  Project: Studentske turnaje
  File: History.vue
  Created: 19.11.2022
  Author: Martin Mores xmores02@stud.fit.vutbr.cz

  Description: List of all tournaments with basic filter
 -->

 <template>
  <div class="matchesHistory">
    <DetailHeading class="HistoryHeading" :headingText="'All tournaments'" />
    <div class="matchesHistoryBody">
      <!-- Bar for filtering tournaments -->
      <FilterComponent
        class="filterComp"
        @responseTnmntsList="
          (tnmntListFromChild) => (this.tournamentsList = tnmntListFromChild)
        "
      />

      <!-- List of tournaments -->
      <TournamentList class="tnmntList" :tournaments="tournamentsList" />
    </div>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import { plainToInstance } from "class-transformer";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import TournamentList from "../components/MainVue/TournamentList.vue";
import FilterComponent from "../components/FilterComponent.vue";
import InfoText from "../components/InfoTextWithLowOpacityComponent.vue";

// Classes
import TournamentClass from "../js/classes/TournamentClass.js";

export default {
  components: {
    TournamentList,
    DetailHeading,
    FilterComponent,
    InfoText,
  },
  data() {
    return {
      tournamentsList: Array(),
    };
  },
  methods: {
    async fetchTournaments() {
      // Fetch all tournaments
      try {
        this.tournamentsList = Array();
        const params = new URLSearchParams();
        const response = await axios.post(
          apiURL.tournaments.getFilteredTnmnt,
          params
        );
        response.data.forEach((element) => {
          this.tournamentsList.push(plainToInstance(TournamentClass, element));
        });
      } catch (error) {
        console.error(error);
      }
    },
  },
  created() {
    this.fetchTournaments();
  },
};
</script>

<style scoped>
.matchesHistory {
  height: 98vh;
  font-family: var(--font-family-primary);
}
.HistoryHeading {
  height: 9%;
}
.matchesHistoryBody {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  width: 100%;
  height: 91%;
}
.filterComp {
  width: 90%;
}
.tnmntList {
  width: 90%;
  height: 80%;
}
</style>