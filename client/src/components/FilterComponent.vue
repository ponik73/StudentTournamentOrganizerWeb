<!-- 
  Project: Studentske turnaje
  File: FilterComponent.vue
  Created: 20.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Filtering tournamets and sending back list of tournaments to the parent
 -->

 <template>
  <div class="mainFilter">
    <form class="detail" @submit.prevent="fetchTournamentsFilter" method="post">
      <section class="formLabelInput">
        <!-- Title filter -->
        <label for="tnmntName">Title:</label>
        <input
          class="inputBox"
          id="tnmntName"
          type="text"
          v-model="tnmntNameFilter"
        />
      </section>
      <section class="formLabelInput">
        <!-- Game type filter -->
        <label for="gameType">Game type:</label>
        <select class="inputBoxSelector" id="gameType" v-model="gameTypeFilter">
          <option v-for="item in gameTypesList" v-bind:key="item">
            {{ item }}
          </option>
        </select>
      </section>
      <section class="formLabelInput">
        <!-- Tournament status filter -->
        <label for="tnmntStatus">Status</label>
        <select class="inputBoxSelector" id="tnmntStatus" v-model="gameStatus">
          <option value="-1">All</option>
          <option value="0">On going</option>
          <option value="1">Finished</option>
          <option value="2">Not started</option>
        </select>
      </section>
      <section class="formLabelInput">
        <!-- Tournament start datetime filter -->
        <label for="startFrom">Start from:</label>
        <input
          class="inputBox"
          id="startFrom"
          type="datetime-local"
          v-model="expectedStartFromFilter"
        />
      </section>
      <section class="formLabelInput">
        <!-- Tournament end datetime filter -->
        <label for="startUntil">Start until:</label>
        <input
          class="inputBox"
          id="startUntil"
          type="datetime-local"
          v-model="expectedStartUntilFilter"
        />
      </section>
      <!-- Submit button -->
      <input type="submit" value="Filter" class="detailButton" />
    </form>
  </div>
</template>

<script>
import axios from "axios";
import { plainToInstance } from "class-transformer";
import apiURL from "../js/apiURL";
import { isEmpty } from "lodash";
import gameTypesList from "../js/gameTypesList.js";
import { ElMessage } from "element-plus";
import ErrorMessageConverter from "../js/ErrorMessageConverter";

// Classes
import TournamentClass from "../js/classes/TournamentClass.js";

export default {
  emits: ["responseTnmntsList"],
  data() {
    return {
      tournaments: Array(),
      tnmntNameFilter: "",
      gameTypeFilter: "",
      gameStatus: "-1",
      expectedStartFromFilter: "",
      expectedStartUntilFilter: "",
      gameTypesList: gameTypesList.gameTypes,
    };
  },
  methods: {
    async fetchTournamentsFilter() {
      // Fetch tournaments by filters and send them back by emitting
      try {
        this.tournaments = Array();
        const params = new URLSearchParams();

        if (!isEmpty(this.tnmntNameFilter))
          params.set("tnmntName", this.tnmntNameFilter);
        if (!isEmpty(this.gameTypeFilter))
          params.set("gameType", this.gameTypeFilter);
        if (!isEmpty(this.expectedStartFromFilter))
          params.set("expectedStartFrom", this.expectedStartFromFilter);
        if (!isEmpty(this.expectedStartUntilFilter))
          params.set("expectedStartUntil", this.expectedStartUntilFilter);

        if (this.gameStatus === "0") {
          // On going
          params.set("alreadyStarted", 1);
          params.set("isFinished", 0);
        } else if (this.gameStatus === "1") {
          // Finished
          params.set("isFinished", 1);
        } else if (this.gameStatus === "2") {
          // Not started
          params.set("alreadyStarted", 0);
        } else if (this.gameStatus === "-1") {
          // All
        } else {
          throw "Wrong tournament status";
        }

        const response = await axios.post(
          apiURL.tournaments.getFilteredTnmnt,
          params
        );
        response.data.forEach((element) => {
          this.tournaments.push(plainToInstance(TournamentClass, element));
        });

        this.$emit("responseTnmntsList", this.tournaments);
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
  },
};
</script>

<style scoped>
.detail {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
  padding: 1rem;
  gap: 1rem;
  background-color: var(--color-secondary);
  border-color: black;
  border-radius: var(--style-border-radius);
}
.formLabelInput {
  display: flex;
  flex-direction: column;
  gap: 15px;
  max-height: 15%;
}
.inputBox {
  width: 95%;
  font-family: var(--font-family-primary);
}
.inputBoxSelector {
  width: 95%;
  height: 22px;
  font-family: var(--font-family-primary);
}
</style>