<!-- 
  Project: Studentske turnaje
  File: TournamentDetail.vue
  Created: 1.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Tournament detail page
 -->

 <template>
  <div v-show="!loading" class="TournamentDetail">
    <section class="heading">
      <!-- Header and pen icon for managing own teams -->
      <DetailHeading :headingText="headingText" />
      <EditPen
        v-if="canEditTournament"
        class="editPen"
        @click="editTournament"
      />
    </section>
    <body class="tnmntDetailBody">
      <!-- Info about tournament -->
      <Info :infos="infos" />
      <section v-show="!showApproval" class="participantsListHeader">
        <!-- List of tournament joined participants -->
        <h2>Participants</h2>
        <ContentBoxList
          class="participantsList"
          :list="tournament.participants"
          :canEdit="true"
          :showDetail="true"
          v-show="tournament.participantsCount > 0"
        >
          <template #buttons="buttonProps">
            <ElTooltip
              class="box-item"
              effect="dark"
              :content="
                buttonProps.isOwn ? 'Leave tournament' : 'Remove participant'
              "
              placement="top"
              :enterable="false"
            >
              <ElIcon
                :size="25"
                :color="'var(--color-stroke)'"
                v-show="
                  (loggedIsCreator && isParticipantApproved(buttonProps.id)) ||
                  buttonProps.isOwn
                "
                @click.stop="
                  removeParticipant(buttonProps.id, buttonProps.isOwn)
                "
              >
                <Delete />
              </ElIcon>
            </ElTooltip>
            <ElTooltip
              class="box-item"
              effect="dark"
              :content="'Approve participant'"
              placement="top"
              :enterable="false"
            >
              <ElIcon
                :size="25"
                :color="'var(--color-stroke)'"
                v-show="
                  loggedIsCreator && !isParticipantApproved(buttonProps.id)
                "
                @click.stop="approveParticipant(buttonProps.id)"
              >
                <Check />
              </ElIcon>
            </ElTooltip>
            <ElTooltip
              class="box-item"
              effect="dark"
              :content="'Remove participant'"
              placement="top"
              :enterable="false"
            >
              <ElIcon
                :size="25"
                :color="'var(--color-stroke)'"
                v-show="
                  loggedIsCreator && !isParticipantApproved(buttonProps.id)
                "
                @click.stop="removeParticipant(buttonProps.id, false)"
              >
                <Close />
              </ElIcon>
            </ElTooltip>
          </template>
        </ContentBoxList>
        <!-- If tournament has no participants yet, show message for user -->
        <p v-show="tournament.participantsCount < 1">
          No participants joined yet
        </p>
      </section>
    </body>
    <section class="secBut">
      <!-- Approve button -->
      <label
        class="detailButton"
        v-show="showApproval"
        @click="approveTournament"
        >Approve</label
      >
      <!-- Decline button -->
      <label
        class="detailButton"
        v-show="showApproval"
        @click="cancelTournament"
        >Decline</label
      >
      <!-- Join tournament button -->
      <label
        class="detailButton"
        v-show="showJoin"
        @click="joinTournament(null)"
        >Join</label
      >
      <!-- Restart tournament, only tournament leader could restart it -->
      <label
        class="detailButton"
        v-if="tournament.alreadyStarted === '1' && canEditTournament"
        @click="restartTnmntClick"
        >Restart tournament</label
      >
      <!-- Generate bracket manually as tournament leader -->
      <label
        class="detailButton"
        v-if="
          tournament.alreadyStarted === '0' &&
          canEditTournament &&
          tournament.isApproved === '1' &&
          tournament.participants.length > 0
        "
        @click="generateBracketClick"
        >Generate bracket manually</label
      >
      <!-- Generate bracket automatically as tournament leader -->
      <label
        class="detailButton"
        v-if="
          tournament.alreadyStarted === '0' &&
          canEditTournament &&
          tournament.isApproved === '1' &&
          tournament.participants.length > 0
        "
        @click="generateBracketAutomaticClick"
        >Generate bracket automatically</label
      >
      <!-- Redirect to tournament bracket page -->
      <label class="detailButton" @click="bracketsClick">Bracket</label>
      <!-- Delete tournament button, only leader could delete it -->
      <label
        class="detailButton"
        v-show="canEditTournament"
        @click="deleteTournamentClick"
        >Delete</label
      >
    </section>

    <!-- If user is joining to the team tournament, show him list of teams where is leader for joining to the tournament -->
    <ElDialog
      v-model="selectTeamDialogVisibility"
      title="Select team"
      :class="'eldialog'"
    >
      <span>(Only teams where you are set as leader)</span>
      <ElRadioGroup
        v-model="selectedTeamName"
        :size="'large'"
        :class="'elradiogroup'"
      >
        <ElRadioButton
          v-for="team in loggedTeams"
          :key="team.teamID"
          :label="team.teamName"
          :class="'elradiobutton'"
        />
      </ElRadioGroup>
      <ElButton @click="joinTournament()">Select</ElButton>
    </ElDialog>
  </div>
</template>

<script>
import axios from "axios";
import apiURL from "../js/apiURL";
import { plainToInstance } from "class-transformer";
import User from "../js/User";
import {
  ElDialog,
  ElIcon,
  ElMessage,
  ElMessageBox,
  ElRadioButton,
  ElRadioGroup,
  ElTooltip,
} from "element-plus";
import { Check, Close, Delete, EditPen } from "@element-plus/icons-vue";
import ErrorMessageConverter from "../js/ErrorMessageConverter";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import Info from "../components/Info.vue";
import ContentBoxList from "../components/ContentBoxList.vue";

// Classes
import TournamentClass from "../js/classes/TournamentClass";
import ParticipantClass from "../js/classes/ParticipantClass";
import TeamClass from "../js/classes/TeamClass";
import InfoClass from "../js/classes/InfoClass";

export default {
  components: {
    DetailHeading,
    Info,
    ContentBoxList,
    ElIcon,
    Delete,
    Check,
    Close,
    EditPen,
    ElDialog,
    ElRadioGroup,
    ElRadioButton,
    ElTooltip,
  },
  props: {
    id: { type: String, required: true },
  },
  data() {
    return {
      tournament: TournamentClass,
      infos: Array(),
      headingText: "Tournament detail",
      showApproval: false,
      showDelete: false,
      loggedIsCreator: false,
      loading: true,
      selectTeamDialogVisibility: false,
      selectedTeamName: null,
      loggedIsInTournament: false,
      loggedTeams: Array(),
      canEditTournament: false,
      userID: User.getUserID(),
    };
  },
  computed: {
    showJoin() {
      return (
        String(this.tournament.isApproved) === "1" 
        && !this.loggedIsInTournament 
        && parseInt(this.tournament.participantsCount) < parseInt(this.tournament.maxParticipants)
        && User.getUsername()
      );
    },
  },
  methods: {
    //#region API
    async fetchData() {
      //#region fetch functions
      const isInTournament = async () => {
        // Checks if current user is already joined in the tournament
        try {
          const params = new URLSearchParams({
            SID: User.getSID(),
            tnmntID: this.tournament.tnmntID,
          });
          const response = await axios.post(
            apiURL.users.isCurrentUserInTournament,
            params
          );
          this.loggedIsInTournament = String(response.data) === "1";
        } catch (error) {
          const errMess = ErrorMessageConverter.convert(
            error.response.data ? error.response.data : error
          );
          ElMessage({
            type: "error",
            message: errMess,
          });
          console.error(error);
        }
      };
      const playerTeams = async () => {
        // Gets team players
        try {
          const idReqResponse = await axios.post(
            apiURL.users.getCurrentUser,
            new URLSearchParams({ SID: User.getSID() })
          );
          const _id = idReqResponse.data;
          const usrReqResponse = await axios.post(
            apiURL.users.getById,
            new URLSearchParams({ id: _id })
          );
          usrReqResponse.data.teams.forEach((e) => {
            this.loggedTeams.push(plainToInstance(TeamClass, e));
          });
          this.loggedTeams.filter((_t) => {
            return _t.leaderID === _id;
          });
        } catch (error) {
          const errMess = ErrorMessageConverter.convert(
            error.response.data ? error.response.data : error
          );
          ElMessage({
            type: "error",
            message: errMess,
          });
          console.error(error);
        }
      };
      //#endregion
      try {
        // Fetch selected tournament data
        const params = new URLSearchParams({ tnmntID: this.id });
        const response = await axios.post(apiURL.tournaments.getById, params);

        this.tournament = plainToInstance(TournamentClass, response.data);
        this.tournament.participants.forEach((item, index) => {
          this.tournament.participants[index] = plainToInstance(
            ParticipantClass,
            item
          );
        });

        await isInTournament();
        if (
          User.getUsername() &&
          !this.loggedIsInTournament &&
          this.tournament.isForTeams === "1"
        )
          await playerTeams();
        this.makeInfos();
      } catch (error) {
        const errMess = ErrorMessageConverter.convert(
          error.response.data ? error.response.data : error
        );
        ElMessage({
          type: "error",
          message: errMess,
        });
      }
    },
    async tournamentApproval(approve, alertProps) {
      // Approve or decline tournament by tournament creator function
      const params = new URLSearchParams({ id: this.tournament.tnmntID });
      const url = Boolean(approve)
        ? apiURL.tournaments.approve
        : apiURL.tournaments.remove;
      try {
        const response = await axios.post(url, params);
        if (response.status != 200) {
          ElMessageBox.alert(
            "Error occured during tournament approval. Please try again",
            "Error occured",
            {
              showClose: false,
              type: "error",
              customStyle: "--el-messagebox-title-color: var(--color-red)",
              confirmButtonText: "OK",
            }
          );
        } else {
          if (!approve) {
            ElMessageBox.alert(alertProps.title, alertProps.mess, {
              showClose: false,
              confirmButtonText: "OK",
              callback: () => {
                this.$router.replace({ path: "/" });
              },
            });
          } else {
            ElMessage({
              type: "success",
              showClose: true,
              message: alertProps.mess,
            });
            this.fetchData();
          }
        }
      } catch (error) {
        console.error(error);
      }
    },
    async approveTournament() {
      // Approve tournament
      const alertProps = {
        mess: "Tournament has been approved",
        title: `Tournament ${this.tournament.tnmntName} starting on ${this.tournament.tnmntStart} was approved!`,
      };
      await this.tournamentApproval(true, alertProps);
    },
    async cancelTournament() {
      // Decline tournament
      const alertProps = {
        mess: "Tournament has been cancelled",
        title: `Tournament ${this.tournament.tnmntName} starting on ${this.tournament.tnmntStart} was cancelled and will be removed!`,
      };
      await this.tournamentApproval(false, alertProps);
    },
    async tournamentJoinRequest(team) {
      // Join to the tournament, participant must wait for tournament leader approval
      let _joined = false;
      const soloJoin = async () => {
        // Joining as user
        try {
          const params = new URLSearchParams({
            tnmntID: this.tournament.tnmntID,
            SID: User.getSID(),
          });
          const response = await axios.post(
            apiURL.users.joinTournament,
            params
          );
          if (response.status != 200) return;
          _joined = true;
        } catch (error) {
          console.error(error);
          const errMess = ErrorMessageConverter.convert(
            error.response.data ? error.response.data : error
          );
          ElMessage({
            type: "error",
            message: errMess,
          });
        }
      };
      const teamJoin = async (_teamID) => {
        // Joining as team
        try {
          const params = new URLSearchParams({
            tnmntID: this.tournament.tnmntID,
            teamID: _teamID,
          });
          const response = await axios.post(
            apiURL.teams.joinTournament,
            params
          );
          _joined = true;
        } catch (error) {
          console.error(error);
          const errMess = ErrorMessageConverter.convert(
            error.response ? error.response.data : error
          );
          ElMessage({
            type: "error",
            message: errMess,
          });
        }
      };
      if (this.tournament.isForTeams === "1") await teamJoin(team.teamID);
      else await soloJoin();
      return _joined;
    },
    async approveParticipant(_id) {
      // Approve participant to the tournament
      try {
        await axios.post(
          apiURL.tournaments.approveParticipant,
          new URLSearchParams({ participantID: _id })
        );
        ElMessage({
          type: "success",
          message: `Participant approved ${
            this.tournament.participants.find((_p) => {
              return _p.idTP === _id;
            }).partName
          }`,
        });
        await this.fetchData();
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
    async removeParticipant(_id, leave) {
      // Decline participant in the tournament, or remove approved participant
      try {
        await axios.post(
          apiURL.tournaments.removeParticipant,
          new URLSearchParams({ participantID: _id })
        );
        await this.fetchData();
        if (leave) {
          ElMessage({ type: "success", message: "Tournament left" });
        } else {
          ElMessage({ type: "success", message: "Participant removed" });
        }
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
    async generateTnmntAutomatically(gameTimeInMinutesParam) {
      // Generates tournament automatically
      try {
        ElMessage({
          type: "info",
          message: "Generating tournament...",
        });

        const params = new URLSearchParams({
          tnmntID: this.id,
          gameTimeInMinutes: gameTimeInMinutesParam,
        });
        await axios.post(apiURL.tournaments.generateBracket, params);

        ElMessage({
          type: "success",
          message: "Tournament successfully generated",
        });

        this.$router.push({
          name: "bracketDetail",
          query: { id: this.id },
        });
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Fail in generating tournament automatically",
        });
      }
    },
    async restartTournament() {
      // Restart started tournament
      try {
        const params = new URLSearchParams({ tnmntID: this.id });
        await axios.post(apiURL.matches.removeAllMatchesFromTnmnt, params);

        this.tournament.alreadyStarted = "0";

        ElMessage({
          type: "success",
          message: "tournament has been restarted",
        });

        this.infos.pop();

        this.infos.push(new InfoClass("Status", this.tournament.getStatus()));
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
    makeInfos() {
      // Creates infos about tournament
      this.infos = this.tournament.TransformToInfos();
      this.showApproval = User.isAdmin() && this.tournament.isApproved === "0";
      this.loggedIsCreator = this.tournament.creatorID === this.userID;
      this.showDelete =
        (User.isAdmin() && this.tournament.isApproved === "1") ||
        this.loggedIsCreator;
    },
    async restartTnmntClick() {
      // Restart tournament bracket, tournament will be stated as not started and new participants could join
      ElMessageBox.confirm(
        "Do you really want to restart tournament? All matches will be deleted and tournament will be joinable for participants.",
        "Tournament restart",
        {
          confirmButtonText: "Yes",
          cancelButtonText: "Cancel",
        }
      ).then(() => {
        this.restartTournament();
      });
    },
    generateBracketClick() {
      // Redirect to generating tournament bracket manually page
      this.$router.push({
        name: "manuallyGenerateBracket",
        query: { id: this.tournament.tnmntID },
      });
    },
    async generateBracketAutomaticClick() {
      // Generate bracket automatically, user must select expected time per round in minutes
      ElMessageBox.prompt(
        "Please input game time per round in minutes",
        "Game time per round",
        {
          confirmButtonText: "OK",
          cancelButtonText: "Cancel",
          inputPattern: /[0-9]+/,
          inputErrorMessage: "Only numbers are allowed",
        }
      ).then(({ value }) => {
        this.generateTnmntAutomatically(value);
      });
    },
    bracketsClick() {
      // Redirect to the bracket detail
      this.$router.push({
        name: "bracketDetail",
        query: { id: this.tournament.tnmntID },
      });
    },
    editTournament() {
      // Redirect for tournament edit
      this.$router.push({
        name: "editTournament",
        query: { id: this.tournament.tnmntID },
      });
    },
    async deleteTournament() {
      // Delete tournament
      const params = new URLSearchParams({ id: this.id });

      try {
        await axios.post(apiURL.tournaments.remove, params);
      } catch (error) {
        console.log(error);
        ElMessage({
          type: "error",
          message: "Error in deleting tournament",
        });
        return;
      }

      ElMessage({
        type: "success",
        message: "Tournament successfully deleted",
      });

      this.$router.back();
    },
    deleteTournamentClick() {
      // Delete tournament confirmation
      ElMessageBox.confirm(
        "Do you really want to delete tournament?",
        "Tournament delete confirmation",
        {
          confirmButtonText: "YES",
          cancelButtonText: "NO",
          type: "warning",
        }
      ).then(() => {
        this.deleteTournament();
      });
    },
    async joinTournament() {
      // Join tournament, function decides if user or team is joining and call another function to join appropriate participant to the tournament
      let joined = false;
      if (this.tournament.isForTeams === "1") {
        this.selectTeamDialogVisibility = !this.selectTeamDialogVisibility;
        if (!this.selectedTeamName) {
          if (!this.selectTeamDialogVisibility) {
            ElMessage({ type: "error", message: "Team not selected" });
          }
          return;
        }
        const _selectedTeam = this.loggedTeams.find((e) => {
          return e.teamName === this.selectedTeamName;
        });
        joined = await this.tournamentJoinRequest(_selectedTeam);
      } else {
        joined = await this.tournamentJoinRequest();
      }
      if (joined) {
        ElMessageBox.alert(
          `You have successfuly joined tournament ${this.tournament.tnmntName}! Wait for approval from tournament creator.`,
          "Joined successfuly",
          {
            showClose: false,
            confirmButtonText: "OK",
            callback: () => {
              this.fetchData();
            },
          }
        );
      }
      this.selectedTeamName = null;
    },
    isParticipantApproved(id) {
      // Checks if participant is approved
      return (
        this.tournament.participants.find((_p) => {
          return _p.idTP === id;
        }).isApproved === "1"
      );
    },
  },
  async created() {
    this.loading = true;
    await this.fetchData();
    this.canEditTournament = this.userID == this.tournament.creatorID;
    this.loading = false;
  },
};
</script>

<style scoped>
.elradiogroup {
  max-height: 20rem;
  width: 100%;
  overflow: auto;
  margin-bottom: 1rem;
}
.elradiobutton {
  --el-radio-button-checked-bg-color: var(--color-primary);
  --el-button-bg-color: var(--color-ternary-light);
  --el-fill-color-blank: var(--color-ternary-light);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  --el-radio-button-checked-text-color: var(--color-stroke);
  --el-radio-button-checked-border-color: var(--color-stroke);
  --el-color-primary: var(--color-stroke);
  width: 100%;
  margin-bottom: 0.5rem;
}
.elradiobutton:last-child {
  margin-bottom: unset;
}
.elradiobutton .span {
  width: 100%;
  color: red;
}
.TournamentDetail {
  height: 95vh;
  width: 98vw;
}
.heading {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  margin-right: 1rem;
}
.editPen {
  width: 30px;
  cursor: pointer;
}
.tnmntDetailBody {
  height: 89%;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  margin-right: 5%;
}
.participantsListHeader {
  width: 30%;
}
.participantsList {
  height: 80%;
}
#headerTeamDetail {
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
}
.secBut {
  display: flex;
  flex-direction: row;
  position: absolute;
  align-items: center;
  right: 0;
  bottom: 0;
}
</style>