<!-- 
  Project: Studentske turnaje
  File: MatchItemComponent.vue
  Created: 22.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Match item
 -->

 <template>
  <div
    v-if="!isLoading"
    class="mainMatchComponentDiv"
    :style="{ 'background-color': setColor() }"
    @click="$emit('selectedItem', match)"
  >
    <section class="teamNames">
      <!-- Participants names -->
      <p v-show="!this.partOneName">
        <em>{{ getParticipantEmptyName(1) }}</em>
      </p>
      <p v-show="this.partOneName">
        {{ this.setParticipantName(this.partOneName) }}
      </p>
      <p v-show="!this.partTwoName">
        <em>{{ getParticipantEmptyName(2) }}</em>
      </p>
      <p v-show="this.partTwoName">
        {{ this.setParticipantName(this.partTwoName) }}
      </p>
    </section>
    <section class="teamScores">
      <!-- Participants scores -->
      <p v-show="match.partOneScore">{{ match.partOneScore }}</p>
      <p v-show="!match.partOneScore">?</p>
      <p v-show="match.partOneScore">{{ match.partTwoScore }}</p>
      <p v-show="!match.partOneScore">?</p>
    </section>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import { ElMessage } from "element-plus";
import User from "../js/User";

export default {
  emits: ["selectedItem"],
  props: {
    match: undefined,
  },
  data() {
    return {
      isLoading: true,
      partOneName: "",
      partOneId: "",
      partTwoName: "",
      partTwoId: "",
    };
  },
  methods: {
    async setParticipantsNames() {
      // Gets match participants names from server
      try {
        const params = new URLSearchParams({ idTP: this.match.partOneID });
        const response = await axios.post(
          apiURL.users.getParticipantInfo,
          params
        );
        this.partOneName = response.data.partName;
        this.partOneId = response.data.partId;

        const paramsTwo = new URLSearchParams({ idTP: this.match.partTwoID });
        const responseTwo = await axios.post(
          apiURL.users.getParticipantInfo,
          paramsTwo
        );
        this.partTwoName = responseTwo.data.partName;
        this.partTwoId = responseTwo.data.partId;
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Fail in getting participant name",
        });
        console.log(error);
      }
    },
    setParticipantName(name) {
      // Sets participant name, if it's too long, cut it and replace end of the name by suspension points
      if (!name) return;

      const strLen = 24;
      if (name.length > strLen) {
        return name.substring(0, strLen - 2) + "...";
      }

      return name;
    },
    getParticipantEmptyName(participantValue) {
      // Gets participant name if is empty or deleted user
      if (participantValue === 1) {
        // Participant 1
        if (this.match.partOneID === null) return "Empty participant";
      } else {
        // Participant 2
        if (this.match.partTwoID === null) return "Empty participant";
      }
      return "Deleted participant";
    },
    setColor() {
      // Sets color for match item according to the if current user is match participant or is in the participated team
      var currentUserId = User.getUserID();
      if (
        this.partOneId === currentUserId ||
        this.partTwoId === currentUserId
      ) {
        return "var(--color-own)";
      }

      return "var(--color-secondary)";
    },
  },
  async beforeMount() {
    await this.setParticipantsNames();
    this.isLoading = false;
  },
};
</script>

<style scoped>
.mainMatchComponentDiv {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  cursor: pointer;
}

.teamNames {
  margin-right: 2rem;
  max-width: 80%;
}

.teamScores {
  color: black;
  font-weight: bold;
  background: var(--color-primary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  text-align: center;
  padding-inline: 1rem;
  max-width: 20%;
}
</style>