<!-- 
  Project: Studentske turnaje
  File: MyMatches.vue
  Created: 1.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Page of all matches
 -->

 <template>
  <div class="mainMyMatches" v-if="!this.pageIsLoading">
    <DetailHeading :headingText="'Lists of matches'" />
    <body class="bodyMatchesLists">
      <section>
        <!-- List of all played matches -->
        <h2>Matches played</h2>
        <MatchesList
          class="matchList"
          v-if="this.playedMatches.length !== 0"
          :list="this.playedMatches"
          @selectedItem="clickedMatch"
        />
        <p v-if="this.playedMatches.length === 0">
          There are no played matches
        </p>
      </section>
      <section>
        <!-- List of all unplayed matches -->
        <h2>Matches in queue</h2>
        <MatchesList
          class="matchList"
          v-if="this.notPlayedMatches.length !== 0"
          :list="this.notPlayedMatches"
          @selectedItem="clickedMatch"
        />
        <p v-if="this.notPlayedMatches.length === 0">
          There are no matches in queue
        </p>
      </section>
    </body>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import { plainToInstance } from "class-transformer";
import { ElMessage } from "element-plus";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import MatchesList from "../components/MatchesList/MatchesList.vue";

// Clases
import MatchClass from "../js/classes/MatchClass";

export default {
  components: {
    DetailHeading,
    MatchesList,
  },
  props: {
    username: { type: String, required: true },
  },
  data() {
    return {
      pageIsLoading: true,
      match: new MatchClass(),
      playedMatches: Array(),
      notPlayedMatches: Array(),
    };
  },
  methods: {
    async getAllPlayedMatches() {
      // Fill list of played matches
      try {
        const params = new URLSearchParams({ isFinished: "1" });
        const response = await axios.post(
          apiURL.matches.getFilteredMatches,
          params
        );
        response.data.forEach((element) => {
          this.playedMatches.push(plainToInstance(MatchClass, element));
        });
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Fail in loading matches",
        });
      }
    },
    async getAllNotPlayedMatches() {
      // Fill list of unplayed matches
      try {
        const params = new URLSearchParams({ isFinished: "0" });
        const response = await axios.post(
          apiURL.matches.getFilteredMatches,
          params
        );
        response.data.forEach((element) => {
          this.notPlayedMatches.push(plainToInstance(MatchClass, element));
        });
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Fail in loading matches",
        });
      }
    },
    clickedMatch(_item) {
      // Redirect to match detail after user clicked on match
      this.$router.push({
        name: "matchDetail",
        query: { id: _item.matchID },
      });
    },
  },
  async created() {
    await this.getAllPlayedMatches();
    await this.getAllNotPlayedMatches();
    this.pageIsLoading = false;
  },
};
</script>

<style scoped>
.mainMyMatches {
  height: 97vh;
}

.bodyMatchesLists {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
  height: 70%;
  width: 100%;
}

.matchList {
  width: 30rem;
}
</style>