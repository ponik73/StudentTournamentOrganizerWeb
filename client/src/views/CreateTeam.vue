<!-- 
  Project: Studentske turnaje
  File: CreateTeam.vue
  Created: 1.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Create team page
 -->

 <template>
  <div class="CreateTeam">
    <DetailHeading class="CreateTeamHeading" :headingText="'Create team'" />
    <body class="bodyCreateTeam">
      <form class="formCreateTeam" method="post" @submit.prevent="createTeam">
        <!-- Formular for team data -->
        <InputBox :label="'Team name:'">
          <template #input>
            <ElInput
              v-model="teamName"
              :placeholder="'Enter team name'"
            ></ElInput>
          </template>
        </InputBox>
        <InputBox :label="'Team logo:'">
          <template #input>
            <ElInput
              v-model="teamLogo"
              :placeholder="'Enter image url'"
            ></ElInput>
          </template>
        </InputBox>
        <InputBox :label="'Add team player:'">
          <template #input>
            <ElAutocomplete
              v-model="autoCompleteValue"
              :fetch-suggestions="autoCompleteSearch"
              :trigger-on-focus="false"
              placeholder="Please input"
              @select="playerSelected"
              @focus="autoCompleteFocus"
            >
              <template #suffix>
                <ElIcon :size="25" @click="addPlayerToTeam">
                  <CirclePlus class="circleBtnCreateTeam" />
                </ElIcon>
              </template>
            </ElAutocomplete>
          </template>
        </InputBox>
        <input type="submit" value="Create" class="detailButton" />
      </form>
      <section>
        <!-- List of players in team -->
        <h2>Team Players:</h2>
        <ContentBoxList :list="teamPlayers" :showDetail="false" :canEdit="true">
          <template #buttons="buttonsProps">
            <ElIcon
              v-show="buttonsProps.id != userId"
              @click="removeFromPlayerList(buttonsProps.id)"
            >
              <Delete class="smallBtnContentBox" />
            </ElIcon>
          </template>
        </ContentBoxList>
      </section>
    </body>
  </div>
</template>

<script>
import { ElAutocomplete, ElIcon, ElMessage, ElMessageBox } from "element-plus";
import axios from "axios";
import apiURL from "../js/apiURL";
import { plainToInstance } from "class-transformer";
import { Delete } from "@element-plus/icons-vue";
import User from "../js/User";

// Components
import ContentBoxList from "../components/ContentBoxList.vue";
import DetailHeading from "../components/DetailHeading.vue";
import InputBox from "../components/InputBox.vue";

// Classes
import PlayerClass from "../js/classes/PlayerClass";

export default {
  components: {
    DetailHeading,
    ContentBoxList,
    InputBox,
    ElAutocomplete,
    ElIcon,
    Delete,
    ElMessage,
    ElMessageBox,
  },
  data() {
    return {
      userId: "",
      username: "",
      teamId: -1,
      teamPlayers: Array(),
      teamName: "",
      teamLogo: "",
      autoCompleteList: Array(),
      autoCompleteValue: "",
      autoCompleteSelected: null,
      showingErrorMessage: {
        notFound: false,
      },
    };
  },
  methods: {
    //#region form
    async createTeam() {
      if (!this.checkTeamName()) return;
      await this.postTeam();
      await this.teamPlayers.slice(1, this.teamPlayers.length).forEach((e) => {
        this.postTeamPlayer(this.teamId, e.userID);
      });
      await ElMessageBox.alert(
        "Team detail will be shown.",
        "Team added succesfully",
        {
          showClose: false,
          confirmButtonText: "OK",
          callback: () => {
            this.$router.replace({
              name: "teamDetail",
              query: { id: this.teamId },
            });
          },
        }
      );
    },
    checkTeamName() {
      if (this.teamName.length < 1) {
        ElMessage({ type: "error", message: "Team name is empty" });
        return false;
      }
      return true;
    },
    //#endregion
    //#region API
    async fetchPlayer(_id) {
      // Fetch player by id
      try {
        const params = new URLSearchParams({ id: _id });
        const response = await axios.post(apiURL.users.getById, params);
        this.teamPlayers.push(plainToInstance(PlayerClass, response.data));
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
    async fetchAllPlayers() {
      // Fetch all users for autocomplete function
      try {
        const response = await axios.get(apiURL.users.getAll);
        response.data.forEach((e) => {
          this.autoCompleteList.push(
            plainToInstance(PlayerClass, e).TransformToAutocomplete()
          );
        });
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
    async postTeam() {
      // Creates team
      try {
        const params = new URLSearchParams({
          teamName: this.teamName,
          SID: User.getSID(),
          logoURL: this.teamLogo,
        });
        const response = await axios.post(apiURL.teams.create, params);
        this.teamId = response.data.id;
        return true;
      } catch (error) {
        const errMess = ErrorMessageConverter.convert(
          error.response.data ? error.response.data : error
        );
        ElMessage({
          type: "error",
          message: errMess,
        });
        return false;
      }
    },
    async postTeamPlayer(_teamId, _userId) {
      // Creates team players
      try {
        const params = new URLSearchParams({
          teamID: _teamId,
          userID: _userId,
        });
        const response = await axios.post(apiURL.users.joinTeam, params);
        return true;
      } catch (error) {
        const errMess = ErrorMessageConverter.convert(
          error.response.data ? error.response.data : error
        );
        ElMessage({
          type: "error",
          message: errMess,
        });
        return false;
      }
    },
    //#endregion
    //#region AutoComplete
    autoCompleteSearch(queryString, cb) {
      // Searches user by queryString
      const results = queryString
        ? this.autoCompleteList.filter(this.createFilter(queryString))
        : this.autoCompleteList;

      if (results.length < 1) {
        this.$message.close;
        ElMessage({
          type: "error",
          message: "Player not found",
          onClose: () => (this.showingErrorMessage.notFound = true),
        });
      }

      cb(results);
    },
    createFilter(queryString) {
      // Filter for players
      return (_player) => {
        return (
          _player.value.toLowerCase().indexOf(queryString.toLowerCase()) === 0
        );
      };
    },
    playerSelected(_selected) {
      // Player was selected for adding to the team
      this.autoCompleteSelected = _selected;
      const _list = this.teamPlayers.slice();
      if (
        _list.filter((_p) => {
          return _p.userID === _selected.id;
        }).length > 0
      )
        ElMessage({ type: "error", message: "Player is already in team!" });
    },
    addPlayerToTeam() {
      // Add player function
      if (this.autoCompleteValue.length < 1)
        ElMessage({
          type: "error",
          message: "Add player by typing player name!",
        });

      if (this.autoCompleteSelected) {
        const _list = this.teamPlayers.slice();

        if (
          _list.filter((_p) => {
            return _p.userID === this.autoCompleteSelected.id;
          }).length > 0
        )
          return;
        this.fetchPlayer(this.autoCompleteSelected.id);
        ElMessage({
          type: "success",
          message: "Player added successfuly!",
        });
        this.autoCompleteValue = "";
      }
      this.autoCompleteSelected = null;
    },
    //#endregion
    removeFromPlayerList(_id) {
      // Removes player from list
      this.teamPlayers = this.teamPlayers.filter((p) => {
        return p.userID !== _id;
      });
    },
  },
  created() {
    this.userId = User.getUserID();
    this.username = User.getUsername();
    this.teamPlayers.push(
      plainToInstance(PlayerClass, {
        username: this.username,
        userID: this.userId,
      })
    );
    this.fetchAllPlayers();
  },
};
</script>

<style scoped>
.succLabel {
  color: var(--color-primary);
  font-weight: 600;
}
.errLabel {
  color: var(--color-red);
  font-weight: 600;
}
.CreateTeam {
  height: 101vh;
  width: 98vw;
}
.CreateTeamHeading {
  height: 9%;
}
.bodyCreateTeam {
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: baseline;
  width: 100%;
  height: 80%;
}
.formCreateTeam {
  width: 20%;
  height: 90%;
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  align-items: center;
}
.circleBtnCreateTeam {
  cursor: pointer;
}
</style>