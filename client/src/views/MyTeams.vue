<!-- 
  Project: Studentske turnaje
  File: MyTeams.vue
  Created: 1.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Page for managing user teams
 -->

<template>
  <div class="mainManageTeams">
    <DetailHeading :headingText="'Manage my teams'" />
    <body class="MainTm">
      <section>
        <!-- List of user teams -->
        <h2>My teams</h2>
        <ListReturnTeamID
          class="contentList"
          :list="player.teamList"
          @selectedItem="setSelectedItem"
          @itemForDelete="deleteTeam"
          @itemForLeave="leaveTeam"
        />
        <InfoText
          class="infoText"
          :msg="'Teams where you are leader are shown with yellow color'"
        />
      </section>
      <section class="InptBx">
        <!-- Form for editing selected team -->
        <form
          class="teamNameInputBoxWithLabel"
          v-if="this.currentTeam.leaderID === this.ID"
          @submit.prevent="updateTeamInfo"
        >
          <label>Team name:</label>
          <textarea type="text" v-model="teamNameForChange" />
          <label>Team logo:</label>
          <textarea type="text" v-model="teamLogoForChange" rows="4" />
          <input class="detailButton" type="submit" value="Save changes" />
        </form>
        <InputBox
          class="teamNameInputBoxWithLabel"
          v-if="this.currentTeam.leaderID === this.ID"
          :label="'Add team player:'"
        >
          <template #input>
            <ElAutocomplete
              v-model="autoCompleteValue"
              :fetch-suggestions="autoCompleteSearch"
              :trigger-on-focus="false"
              placeholder="Please input"
              @select="playerSelected"
            >
              <template #suffix>
                <ElIcon
                  v-if="autoCompleteSelected"
                  :size="25"
                  @click="addPlayerToTeam"
                >
                  <CirclePlus class="circleBtnAddTeamPlayer" />
                </ElIcon>
              </template>
            </ElAutocomplete>
          </template>
        </InputBox>
        <!-- Info about team when user is not team leader -->
        <section
          v-if="this.currentTeam"
          v-show="this.currentTeam.leaderID !== this.ID"
        >
          <p>Team name:</p>
          <p>
            <strong>{{ this.currentTeam.teamName }}</strong>
          </p>
        </section>
        <!-- Move to team detail page -->
        <button
          class="detailButton"
          v-show="this.currentTeam"
          @click="routeToTheTeam"
        >
          Go to team detail
        </button>
      </section>
      <section>
        <!-- List of team members -->
        <h2>Team members</h2>
        <ListReturnTeamID
          class="contentList"
          :list="teamMembers"
          :couldDelete="this.currentTeam.leaderID === this.ID"
          :leaderID="this.currentTeam.leaderID"
          :teamID="this.currentTeam.teamID"
          @itemForDelete="this.deleteTeamMember"
        />
        <InfoText
          class="infoText"
          v-show="this.currentTeam"
          :msg="'Team leader is shown with yellow color'"
        />
      </section>
    </body>
  </div>
</template>

<script>
import axios from "axios";
import User from "../js/User";
import { plainToInstance } from "class-transformer";
import { ElAutocomplete, ElMessage, ElMessageBox, ElIcon } from "element-plus";
import apiURL from "../js/apiURL";
import { CirclePlus } from "@element-plus/icons-vue";

// Components
import DetailHeading from "../components/DetailHeading.vue";
import ListReturnTeamID from "../components/ListReturnItemId/ListReturnItem.vue";
import InfoText from "../components/InfoTextWithLowOpacityComponent.vue";
import InputBox from "../components/InputBox.vue";
import Info from "../components/Info.vue";

// Classes
import PlayerClass from "../js/classes/PlayerClass";

export default {
  components: {
    DetailHeading,
    ListReturnTeamID,
    InfoText,
    Info,
    ElMessageBox,
    ElIcon,
    InputBox,
    ElAutocomplete,
    CirclePlus,
  },
  data() {
    return {
      ID: undefined,
      player: new PlayerClass(),
      currentTeam: "",
      teamMembers: Array(),
      infos: Array(),
      teamNameForChange: "",
      teamLogoForChange: "",
      teamMemberToAdd: "",
      autoCompleteValue: "",
      autoCompleteList: Array(),
      autoCompleteSelected: null,
    };
  },

  methods: {
    //#region Async methods to communicate with API
    async fetchPlayer(_id) {
      // Gets player by id
      try {
        const params = new URLSearchParams({ id: _id });
        const response = await axios.post(apiURL.users.getById, params);

        this.teamMembers.push(plainToInstance(PlayerClass, response.data));
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Error in fetching player",
        });
      }
    },
    async fetchTeamUserData() {
      // Fetch current logged user
      this.ID = User.getUserID();
      const params = new URLSearchParams({ id: this.ID });
      const response = await axios.post(apiURL.users.getById, params);
      this.player = plainToInstance(PlayerClass, response.data);
      this.player.setTeamList();
    },
    async fetchAutoCompleteList() {
      // Gets list of potentional all
      try {
        const response = await axios.get(apiURL.users.getAll);
        if (response.status != 200) throw new error();
        response.data.forEach((e) => {
          this.autoCompleteList.push(
            plainToInstance(PlayerClass, e).TransformToAutocomplete()
          );
        });
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Failure in fetching data for auto complete list",
        });
      }
    },
    async setSelectedItem(_item) {
      // Team was selected
      this.currentTeam = _item;
      this.teamNameForChange = _item.teamName;
      this.teamLogoForChange = _item.logoUrl;
      await this.setTeamMembers();
    },
    async setTeamMembers() {
      // Fill list of team players
      this.teamMembers = Array();
      const params = new URLSearchParams({ teamID: this.currentTeam.teamID });
      const response = await axios.post(apiURL.teams.getTeamPlayers, params);
      response.data.forEach((element) => {
        this.teamMembers.push(plainToInstance(PlayerClass, element));
      });
    },
    async updateTeamInfo() {
      // Update function for team infos
      if (!this.currentTeam) {
        ElMessage({
          type: "warning",
          message: "No team is selected",
        });
      } else {
        const params = new URLSearchParams({
          teamID: this.currentTeam.teamID,
          teamName: this.teamNameForChange,
          logoUrl: this.teamLogoForChange,
        });
        const response = await axios.post(apiURL.teams.update, params);
        this.currentTeam.teamName = this.teamNameForChange;
        this.currentTeam.logoUrl = this.teamLogoForChange;
        ElMessage({
          type: "success",
          message: "Changes saved",
        });
      }
    },
    async deleteTeamMember(_item) {
      // Removing member from team
      try {
        ElMessageBox.confirm(
          "Do you really want to remove " +
            _item.username +
            " from team members?",
          "Remove confirmation",
          {
            confirmButtonText: "YES",
            cancelButtonText: "NO",
            type: "warning",
          }
        ).then(() => {
          this.teamMembers = this.teamMembers.filter(function (item) {
            return item.userID !== _item.userID;
          });
          const params = new URLSearchParams({
            userID: _item.userID,
            teamID: this.currentTeam.teamID,
          });
          const response = axios.post(apiURL.teams.removeMember, params);
          ElMessage({
            type: "success",
            message: "Remove completed",
          });
        });
      } catch (error) {
        ElMessageBox.alert(
          "Fail in removing team member",
          "Delete team member",
          {
            showClose: false,
            confirmButtonText: "OK",
            type: "error",
          }
        );
      }
    },
    async deleteTeam(_item) {
      // Deleting team as leader
      try {
        ElMessageBox.confirm(
          'Do you really want to delete team "' + _item.teamName + '"?',
          "Delete confirmation",
          {
            confirmButtonText: "YES",
            cancelButtonText: "NO",
            type: "warning",
          }
        ).then(() => {
          this.player.teamList = this.player.teamList.filter(function (item) {
            return item.teamID !== _item.teamID;
          });
          const params = new URLSearchParams({ id: _item.teamID });
          const response = axios.post(apiURL.teams.remove, params);
          this.currentTeam = "";
          this.teamMembers = Array();
        });
      } catch (error) {
        ElMessageBox.alert("Fail in leaving team :(", "Leave team", {
          showClose: false,
          confirmButtonText: "OK",
          type: "error",
        });
      }
    },
    async leaveTeam(_item) {
      // Users leave team where is not leader
      try {
        ElMessageBox.confirm(
          'Do you really want to leave team "' + _item.teamName + '"?',
          "Leave confirmation",
          {
            confirmButtonText: "YES",
            cancelButtonText: "NO",
            type: "warning",
          }
        ).then(() => {
          this.player.teamList = this.player.teamList.filter(function (item) {
            return item.teamID !== _item.teamID;
          });
          const params = new URLSearchParams({
            userID: User.getUserID(),
            teamID: _item.teamID,
          });
          const response = axios.post(apiURL.teams.removeMember, params);
          this.currentTeam = "";
          this.teamMembers = Array();
          ElMessage({
            type: "success",
            message: "You left the team!",
          });
        });
      } catch (error) {
        ElMessageBox.alert("Fail in leaving team :(", "Leave team", {
          showClose: false,
          confirmButtonText: "OK",
          type: "error",
        });
      }
    },
    //#endregion
    routeToTheTeam() {
      // Go to the team detail
      this.$router.push({
        name: "teamDetail",
        query: { id: this.currentTeam.teamID },
      });
    },
    autoCompleteSearch(queryString, callBack) {
      // Auto completing adding players to the team
      const results = queryString
        ? this.autoCompleteList.filter(this.createFilter(queryString))
        : this.autoCompleteList;

      callBack(results);
    },
    createFilter(queryString) {
      // Filtering list of players
      return (_player) => {
        return (
          _player.value.toLowerCase().indexOf(queryString.toLowerCase()) === 0
        );
      };
    },
    addPlayerToTeam() {
      // Adding player to the team
      if (this.autoCompleteSelected) {
        const _list = this.teamMembers.slice();

        if (
          _list.filter((_p) => {
            return _p.userID === this.autoCompleteSelected.id;
          }).length > 0
        ) {
          return;
        }

        try {
          const params = new URLSearchParams({
            teamID: this.currentTeam.teamID,
            userID: this.autoCompleteSelected.id,
          });
          const response = axios.post(apiURL.users.joinTeam, params);
        } catch (error) {
          console.log(error);
          ElMessage({
            type: "error",
            message: "Error occured in adding player to the team 😬",
          });
          return;
        }

        this.fetchPlayer(this.autoCompleteSelected.id);
        this.autoCompleteValue = "";

        ElMessage({
          type: "success",
          message: "Player successfully added to the team",
        });
      }

      this.autoCompleteSelected = null;
    },
    playerSelected(_selectedPlayer) {
      // Player was selected for adding to the team
      this.autoCompleteSelected = _selectedPlayer;
      const _list = this.teamMembers.slice();
      if (
        _list.filter((_p) => {
          return _p.userID === _selectedPlayer.id;
        }).length > 0
      ) {
        ElMessage({
          type: "error",
          message: "Player is already in the team",
        });
        this.autoCompleteSelected = null;
        this.autoCompleteValue = "";
      }
    },
  },
  created() {
    this.fetchTeamUserData();
    this.fetchAutoCompleteList();
  },
};
</script>

<style scoped>
.mainManageTeams {
  height: 96vh;
}

.MainTm {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
  height: 89%;
}

.contentList {
  width: 25rem;
  height: 70%;
}

.InptBx {
  margin-top: 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 20%;
}

.teamNameInputBoxWithLabel {
  display: flex;
  flex-direction: column;
  gap: 15px;
  background: var(--color-secondary);
  padding: 1rem;
  margin: 1rem;
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  font-size: x-large;
  font-family: var(--font-family-primary);
  width: 100%;
}

.infoText {
  text-align: center;
}

.circleBtnAddTeamPlayer {
  cursor: pointer;
}

textarea {
  resize: none;
  font-family: var(--font-family-primary);
}

p {
  font-family: var(--font-family-primary);
  font-size: x-large;
}
</style>