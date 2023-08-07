<!-- 
  Project: Studentske turnaje
  File: MatchEdit.vue
  Created: 23.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Match edit page
 -->

 <template>
  <div class="mainEditMatch">
    <DetailHeading class="heading" :headingText="'Edit match'" />
    <body class="bodyEditMatch">
      <!-- Formular for editing match -->
      <form class="formEditMatch" @submit.prevent="updateMatch">
        <section class="scores">
          <section class="formLabelInput">
            <!-- Participant's 1 name, and score -->
            <label v-if="match.partOneName" class="participantName"
              ><strong>{{ match.partOneName }}</strong></label
            >
            <label v-if="!match.partOneName" class="participantName"
              ><em>Unknown participant</em></label
            >
            <label for="partOneScore">Part One Score:</label>
            <input
              id="partOneScore"
              class="inputBoxScore"
              type="number"
              v-model="match.partOneScore"
              max="999999"
            />
          </section>
          <section class="formLabelInput">
            <!-- Participant's 2 name, and score -->
            <label v-if="match.partTwoName" class="participantName"
              ><strong>{{ match.partTwoName }}</strong></label
            >
            <label v-if="!match.partTwoName" class="participantName"
              ><em>Unknown participant</em></label
            >
            <label for="partTwoScore">Part Two Score:</label>
            <input
              id="partTwoScore"
              class="inputBoxScore"
              type="number"
              v-model="match.partTwoScore"
              max="999999"
            />
          </section>
        </section>
        <!-- Switch if match is finished -->
        <ElSwitch
          v-model="match.isFinished"
          active-value="1"
          inactive-value="0"
          active-text="Finished"
          inactive-text="Not finished"
        />
        <!-- Update match button -->
        <input type="submit" value="Update Match" class="detailButton" />
      </form>
    </body>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import { ElMessage, ElSwitch } from "element-plus";
import { plainToInstance } from "class-transformer";

// Classes
import MatchClass from "../js/classes/MatchClass";

// Components
import DetailHeading from "../components/DetailHeading.vue";

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
      match: MatchClass,
    };
  },
  methods: {
    async fetchData() {
      // Fetch match data on create
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
    async updateMatch() {
      // Update match if validation are OK, validations are only if tournament creator is finishing the match
      if (this.match.isFinished === "1") {
        if (
          !this.match.partOneScore ||
          (!this.match.partTwoScore &&
            this.match.partOneScore != 0 &&
            this.match.partTwoScore != 0)
        ) {
          ElMessage({
            type: "error",
            message:
              "Participant score can not be empty when match is finished 🤌",
          });
          return;
        }

        if (this.match.partOneScore == this.match.partTwoScore) {
          ElMessage({
            type: "error",
            message: "Match can not end as draw in bracket tournament 🏆",
          });
          return;
        }
      }

      try {
        const params = new URLSearchParams({ matchID: this.id });
        params.set("partOneScore", this.match.partOneScore);
        params.set("partTwoScore", this.match.partTwoScore);
        await axios.post(apiURL.matches.update, params);

        if (this.match.isFinished === "1") {
          const params2 = new URLSearchParams({ matchID: this.id });
          await axios.post(apiURL.matches.finishMatch, params2);
        }

        ElMessage({
          type: "success",
          message: "Match successfully updated",
        });
        this.$router.back();
      } catch (error) {
        console.log(error);
        ElMessage({
          type: "error",
          message: "Failure in updating this match 🙁",
        });
      }
    },
  },
  created() {
    this.fetchData();
  },
};
</script>

<style scoped>
.mainEditMatch {
  height: 97vh;
}

.heading {
  height: 9%;
}

.bodyEditMatch {
  height: 91%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.formEditMatch {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4rem;
  background: var(--color-secondary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  width: 50%;
  padding: 2rem;
}

.scores {
  display: flex;
  flex-direction: row;
  justify-content: center;
  gap: 6rem;
}

.formLabelInput {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
  font-family: var(--font-family-primary);
  font-size: large;
}

.participantName {
  font-size: x-large;
}

.inputBoxScore {
  font-family: var(--font-family-primary);
  font-size: xx-large;
  width: 50%;
  text-align: center;
}
</style>