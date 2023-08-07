<!-- 
  Project: Studentske turnaje
  File: GenerateBracketManually.vue
  Created: 24.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Page for manual generating first tournament round
 -->

 <template>
  <div v-if="!loading" class="mainGenerateManually">
    <DetailHeading :heading-text="'Generate bracket manually'" />
    <section class="bodySecGenerateManually">
      <section class="infosMinutes">
        <!-- Tournament name and time in minutes per round -->
        <Info :infos="infos" />
        <section>
          <label>Time per round in minutes: </label>
          <input
            class="inputBoxMinutes"
            type="number"
            min="1"
            max="10080"
            step="1"
            v-model="minutesPerRound"
          />
        </section>
      </section>
      <section class="lists">
        <section class="participantsListHeader">
          <!-- List of matches -->
          <h2>First round matches</h2>
          <MatchList
            class="contentListParticipants"
            :list="matches"
            :activeIndex="activeIndex"
          />
          <section>
            <button
              v-if="participantsList.length < tournament.participants.length"
              class="detailButton"
              @click="removeLast"
            >
              Remove last
            </button>
            <button
              v-if="participantsList.length < tournament.participants.length"
              class="detailButton"
              @click="clearRound"
            >
              Clear round
            </button>
          </section>
        </section>
        <section class="participantsListHeader">
          <!-- List of participants -->
          <h2>Participants</h2>
          <ListReturnTeamID
            class="contentListParticipants"
            :list="participantsList"
            @selectedItem="setSelectedItem"
            @itemForApprove="approveItem"
            @itemForDecline="declineItem"
          />

          <!-- Generate tournament button, visible only when all participants are in tournament match -->
          <button
            v-if="participantsList.length < 1"
            class="detailButton"
            @click="generateTournament"
          >
            Generate tournament
          </button>
        </section>
      </section>
      <InfoText class="infoText" :msg="'Select all rounds first participants, and when all rounds will be filled with one participant, then system will allow you to add second participant to all the matches. This feature is because in the first round there are not allowed any matches without participants.'" />
      <InfoText class="infoText" :msg="'And finally when you assign all participants to the matches, you will see generate tournament button!'" />
    </section>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import { plainToInstance } from "class-transformer";
import { ElMessageBox, ElMessage, ElIcon } from "element-plus";
import ErrorMessageConverter from "../js/ErrorMessageConverter";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import Info from "../components/Info.vue";
import ListReturnTeamID from "../components/ListReturnItemId/ListReturnItem.vue";
import MatchList from "../components/MatchGeneratorList/MatchList.vue";
import InfoText from "../components/InfoTextWithLowOpacityComponent.vue";

// Others
import TournamentClass from "../js/classes/TournamentClass";
import ParticipantClass from "../js/classes/ParticipantClass";
import MatchClass from "../js/classes/MatchClass";
import InfoClass from "../js/classes/InfoClass";
import User from "../js/User";

export default {
  components: {
    DetailHeading,
    Info,
    ElIcon,
    ListReturnTeamID,
    MatchList,
    InfoText,
  },
  props: {
    id: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      loading: true,
      isAuthorized: false,
      tournament: TournamentClass,
      participantsList: Array(),
      infos: Array(),
      matches: Array(),
      activeIndex: 0,
      minutesPerRound: 15,
    };
  },
  methods: {
    //#region Fetching data on create
    async fetchData() {
      // Fetch data for participants
      try {
        const params = new URLSearchParams({ tnmntID: this.id });
        const response = await axios.post(apiURL.tournaments.getById, params);

        this.tournament = plainToInstance(TournamentClass, response.data);

        if (this.tournament.creatorID != User.getUserID()) {
          ElMessageBox.alert(
            "You are not creator of this tournament. You will be redirected to the home.",
            "Not authorized",
            {
              showClose: false,
              type: "error",
              customStyle: "--el-messagebox-title-color: var(--color-red)",
              confirmButtonText: "OK",
              callback: () => this.$router.replace({ name: "home" }),
            }
          );
          return;
        }

        this.isAuthorized = true;

        this.tournament.participants.forEach((item, index) => {
          this.tournament.participants[index] = plainToInstance(
            ParticipantClass,
            item
          );
          this.participantsList.push(plainToInstance(ParticipantClass, item));
        });

        this.makeInfos();
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
    async getFirstRoundMatches() {
      // Get list of n empty matches for tournament
      try {
        const params = new URLSearchParams({ tnmntID: this.id });
        const response = await axios.post(
          apiURL.tournaments.getEmptyFirstRound,
          params
        );

        response.data.forEach((element) => {
          this.matches.push(plainToInstance(MatchClass, element));
        });

        if (this.matches.length > 0) this.matches[0].partOneName = "➡";
      } catch (error) {
        console.log(error);
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
    makeInfos() {
      // Create list of infos, one info is there only, tournament title
      this.infos = Array();
      this.infos.push(
        new InfoClass("Tournament title", this.tournament.tnmntName)
      );
    },
    setSelectedItem(_item) {
      // Selecting participant from list
      if (_item.isApproved === "0") {
        ElMessage({
          type: "error",
          message: "You can not select not approved participant",
        });
        return;
      }

      this.participantsList = this.participantsList.filter(function (item) {
        return item !== _item;
      });

      this.setItemAtActiveIndex(true, _item);

      this.activeIndex++;
      this.activeIndex++;

      if (
        this.activeIndex / this.matches.length >= 2 &&
        this.activeIndex % 2 == 0
      ) {
        this.activeIndex = 1;
      }

      this.setItemAtActiveIndex(false, null);
    },
    removeLast() {
      // Remove last added participant from matches and move him back to participants list
      if (this.activeIndex === 0) {
        ElMessage({
          type: "info",
          message: "There are no participants selected yet",
        });
        return;
      }

      if (this.activeIndex < this.matches.length * 2) {
        if (this.activeIndex % 2 == 0)
          this.matches[Math.floor(this.activeIndex / 2)].partOneName = "";
        else this.matches[Math.floor(this.activeIndex / 2)].partTwoName = "";
      }

      this.activeIndex--;
      this.activeIndex--;

      if (this.activeIndex < 0) {
        this.activeIndex = this.matches.length * 2 - 2;
      }

      const currentPartId =
        this.activeIndex % 2 === 0
          ? this.matches[Math.floor(this.activeIndex / 2)].partOneID
          : this.matches[Math.floor(this.activeIndex / 2)].partTwoID;

      const item = this.tournament.participants.find(
        (element) => element.idTP === currentPartId
      );

      this.participantsList.push(item);

      this.setItemAtActiveIndex(false, null);
    },
    clearRound() {
      // Clear matches and move all participants back to list
      while (this.activeIndex > 0) {
        this.removeLast();
      }
    },
    async approveItem(_item) {
      // Approve not approved participant
      try {
        const params = new URLSearchParams({ participantID: _item.idTP });
        const response = await axios.post(
          apiURL.tournaments.approveParticipant,
          params
        );

        _item.isApproved = "1";
        this.tournament.participants.find(
          (element) => element.idTP === _item.idTP
        ).isApproved = "1";

        ElMessage({
          type: "success",
          message: "User approved",
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
    async declineItem(_item) {
      // Decline participant
      ElMessage({
        type: "info",
        message: "declined item: " + _item.idTP + ", " + _item.partName,
      });
    },
    setItemAtActiveIndex(nameArrowFlag, _item) {
      // Setting match row
      if (this.activeIndex % 2 == 0) {
        if (nameArrowFlag) {
          this.matches[Math.floor(this.activeIndex / 2)].partOneID = _item.idTP;
          this.matches[Math.floor(this.activeIndex / 2)].partOneName =
            _item.partName;
        } else {
          if (this.participantsList.length > 0) {
            this.matches[Math.floor(this.activeIndex / 2)].partOneID = "";
            this.matches[Math.floor(this.activeIndex / 2)].partOneName = "➡";
          }
        }
      } else {
        if (nameArrowFlag) {
          this.matches[Math.floor(this.activeIndex / 2)].partTwoID = _item.idTP;
          this.matches[Math.floor(this.activeIndex / 2)].partTwoName =
            _item.partName;
        } else {
          if (this.participantsList.length > 0) {
            this.matches[Math.floor(this.activeIndex / 2)].partTwoID = "";
            this.matches[Math.floor(this.activeIndex / 2)].partTwoName = "➡";
          }
        }
      }
    },
    matchesToStringJson() {
      return JSON.stringify(this.matches);
    },
    async generateTournament() {
      // Generates tournament bracket with matches
      ElMessage({
        type: "info",
        message: "Generating tournament...",
      });

      try {
        const params = new URLSearchParams({
          tnmntID: this.id,
          matches: this.matchesToStringJson(),
          gameTimeInMinutes: Math.round(this.minutesPerRound),
        });
        const response = await axios.post(
          apiURL.tournaments.generateBracketManualy,
          params
        );

        ElMessage({
          type: "info",
          message: "Tournament generated successfully",
        });

        this.$router.replace({
          name: "bracketDetail",
          query: { id: this.id },
        });
      } catch (error) {
        console.log(error);
        ElMessage({
          type: "error",
          message: "Error in generating tournaments",
        });

        try {
          const params = new URLSearchParams({ tnmntID: this.id });
          await axios.post(apiURL.matches.removeAllMatchesFromTnmnt, params);
        } catch (error) {
          console.log(error);
          ElMessage({
            type: "error",
            message: "Error in clearing tournament",
          });
        }
      }
    },
  },
  async created() {
    await this.fetchData();

    if (this.isAuthorized) {
      await this.getFirstRoundMatches();
      this.loading = false;
    }
  },
};
</script>

<style scoped>
.mainGenerateManually {
  height: 98vh;
}

.bodySecGenerateManually {
  height: 91%;
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-right: 3rem;
}

.infosMinutes {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
  align-items: center;
  width: 100%;
  font-family: var(--font-family-primary);
  font-size: large;
}

.inputBoxMinutes {
  font-family: var(--font-family-primary);
  font-size: large;
  text-align: center;
}

.lists {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
  width: 100%;
  height: 80%;
}

.participantsListHeader {
  display: flex;
  flex-direction: column;
  align-items: center;
  max-height: 100%;
  width: 30%;
}

.contentListParticipants {
  width: 100%;
}

.frButtons {
  display: flex;
  flex-direction: row;
}

.infoText {
  /* Margin on the left is set to 3rem as default so because of that, here is the difference, but in the result the text will be centered to the middle */
  text-align: center;
  margin-right: 2rem;
  margin-left: 5rem;
}
</style>