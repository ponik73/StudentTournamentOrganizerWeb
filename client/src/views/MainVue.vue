<!-- 
  Project: Studentske turnaje
  File: MainVue.vue
  Created: 27.10.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Main page of the application
 -->

 <template>
  <div class="main" v-show="!loading">
    <header class="headerMain">
      <section class="headerInfos">
        <!-- Infos labels -->
        <label class="headerSection">Create tournaments app</label>
        <label class="headerSection">Search for players and tournaments</label>

        <!-- User's username and person icon -->
        <UsrIcon v-show="username" class="usrIcon" />
        <label class="headerSection"
          ><em>{{ this.username }}</em></label
        >
      </section>
      <section v-show="username" class="logoutSec">
        <!-- Logout icon -->
        <logout @click="logOut" />
      </section>
      <section v-show="!username">
        <!-- Login and register router links -->
        <RouterLink
          class="authorizationRouteLinkers"
          :to="{ name: 'LoginUser' }"
          >Login</RouterLink
        >
        <RouterLink
          class="authorizationRouteLinkers"
          :to="{ name: 'RegisterUser' }"
          >Register</RouterLink
        >
      </section>
    </header>
    <body class="divMain">
      <section class="listsWithHeaders">
        <!-- List of not started tournaments -->
        <section class="listHeader">
          <h2>Not started tournaments</h2>
          <TournamentList
            class="listContent"
            :tournaments="tournamentsList"
            :reloadFun="fetchTournaments"
          />
        </section>
        <section class="listHeaderSecond">
          <header class="hdr">
            <!-- List of players with players filter -->
            <h2 v-show="!playerSearch.showInput">Players</h2>
            <ElTooltip
              effect="dark"
              :content="'Filter players'"
              placement="bottom"
              :enterable="false"
            >
              <ElBadge
                :isDot="true"
                :hidden="!playerSearch.filterOn"
                v-show="!playerSearch.showInput"
              >
                <ElIcon
                  :size="30"
                  @click="playerSearch.showInput = true"
                  :style="'cursor: pointer;'"
                >
                  <Filter />
                </ElIcon>
              </ElBadge>
            </ElTooltip>
            <ElInput
              v-model="playerSearch.input"
              v-show="playerSearch.showInput"
              :placeholder="'Player name'"
              :clearable="true"
              :class="'aa'"
              @input="filterPlayers"
            >
              <template #prepend>
                <ElTooltip
                  effect="dark"
                  :content="'Hide filter'"
                  placement="bottom"
                  :enterable="false"
                >
                  <ElButton
                    :icon="'Hide'"
                    @click="playerSearch.showInput = false"
                  />
                </ElTooltip>
              </template>
            </ElInput>
          </header>
          <ContentBoxList
            class="listContent"
            :list="displayed.playerList"
            :canEdit="true"
            :showDetail="true"
          />
        </section>
        <section class="listHeaderSecond">
          <header class="hdr">
            <!-- List of teams with teams filter -->
            <h2 v-show="!teamSearch.showInput">Teams</h2>
            <ElTooltip
              effect="dark"
              :content="'Filter teams'"
              placement="bottom"
              :enterable="false"
            >
              <ElBadge
                :isDot="true"
                :hidden="!teamSearch.filterOn"
                v-show="!teamSearch.showInput"
              >
                <ElIcon
                  :size="30"
                  @click="teamSearch.showInput = true"
                  :style="'cursor: pointer;'"
                >
                  <Filter />
                </ElIcon>
              </ElBadge>
            </ElTooltip>
            <ElInput
              v-model="teamSearch.input"
              v-show="teamSearch.showInput"
              :placeholder="'Team name'"
              :clearable="true"
              :class="'aa'"
              @input="filterTeams"
            >
              <template #prepend>
                <ElTooltip
                  effect="dark"
                  :content="'Hide filter'"
                  placement="bottom"
                  :enterable="false"
                >
                  <ElButton
                    :icon="'Hide'"
                    @click="teamSearch.showInput = false"
                  />
                </ElTooltip>
              </template>
              <template #append>
                <ElCheckbox
                  :label="'My teams'"
                  v-show="username"
                  @change="showOwnTeams"
                />
              </template>
            </ElInput>
          </header>

          <ContentBoxList
            class="listContent"
            :list="displayed.teamList"
            :canEdit="true"
            :showDetail="true"
          />
        </section>
      </section>
      <section class="routerLinks">
        <!-- Main page buttons under lists -->
        <RouterLink class="MainVueRouterLink" :to="{ name: 'matchHistory' }"
          >All tournaments</RouterLink
        >
        <RouterLink
          class="MainVueRouterLink"
          :to="{ name: 'createTournament', params: { username: 'loggedUser' } }"
          v-show="username"
          >Create tournament</RouterLink
        >
        <RouterLink class="MainVueRouterLink" :to="{ name: 'myMatches' }"
          >All matches</RouterLink
        >
        <RouterLink
          class="MainVueRouterLink"
          :to="{ name: 'EditPlayer' }"
          v-show="username"
          >Edit player profile</RouterLink
        >
        <RouterLink
          class="MainVueRouterLink"
          :to="{ name: 'createTeam' }"
          v-show="username"
          >Create team</RouterLink
        >
        <RouterLink
          class="MainVueRouterLink"
          v-show="username"
          :to="{ name: 'myTeams' }"
          >Manage my teams</RouterLink
        >
      </section>
    </body>
  </div>
</template>

<script>
import axios from "axios";
import {
  ElBadge,
  ElButton,
  ElCheckbox,
  ElIcon,
  ElInput,
  ElMessage,
  ElTooltip,
} from "element-plus";
import { plainToInstance } from "class-transformer";
import { User as UsrIcon } from "@element-plus/icons-vue";
import apiURL from "../js/apiURL";
import IconCheck from "../assets/icons/IconCheck.vue";
import IconCross from "../assets/icons/IconCross.vue";
import User from "../js/User";
import logout from "../assets/icons/logout.vue";
import ErrorMessageConverter from "../js/ErrorMessageConverter";

// Components
import ContentBoxList from "../components/ContentBoxList.vue";
import TournamentList from "../components/MainVue/TournamentList.vue";

// Classes
import PlayerClass from "../js/classes/PlayerClass";
import TeamClass from "../js/classes/TeamClass";
import TournamentClass from "../js/classes/TournamentClass";

export default {
  components: {
    TournamentList,
    ContentBoxList,
    IconCheck,
    IconCross,
    UsrIcon,
    logout,
    ElInput,
    ElButton,
    ElCheckbox,
    ElIcon,
    ElTooltip,
    ElBadge,
  },
  data() {
    return {
      tournamentsList: Array(),
      playerList: Array(),
      teamList: Array(),
      displayed: {
        playerList: Array(),
        teamList: Array(),
      },
      username: undefined,
      id: undefined,
      teamSearch: {
        input: null,
        showInput: false,
        ownOnly: false,
        ownTeams: Array(),
        filterOn: false,
      },
      playerSearch: {
        input: null,
        showInput: false,
        filterOn: false,
      },
      loading: false,
    };
  },
  methods: {
    async fetchTournaments() {
      // Fetch all not started tournaments
      try {
        if (User.getUsername()) await User.setAdminFlag();

        this.tournamentsList = Array();
        const params = new URLSearchParams();
        params.set("alreadyStarted", 0);

        if (!User.isAdmin()) {
          params.set("isApproved", 1);
        }

        const response = await axios.post(
          apiURL.tournaments.getFilteredTnmnt,
          params
        );
        response.data.forEach((element) => {
          this.tournamentsList.push(plainToInstance(TournamentClass, element));
        });
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Error in loading tournaments list",
        });
      }
    },
    async fetchPlayers() {
      // Fetch all players
      try {
        const response = await axios.get(apiURL.users.getAll);
        if (response.data.length < 1) return;
        response.data.forEach((element) => {
          this.playerList.push(plainToInstance(PlayerClass, element));
        });
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Error in loading players list",
        });
      }
    },
    getCurrentUser() {
      // Sets user's username
      this.username = User.getUsername();
    },
    async fetchTeams() {
      // Fetch all teams
      try {
        const response = await axios.get(apiURL.teams.getAll);
        if (response.data.length < 1) return;
        response.data.forEach((element) => {
          this.teamList.push(plainToInstance(TeamClass, element));
        });
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Error in loading teams list",
        });
      }
    },
    async logOut() {
      // Logout user and refresh page
      try {
        const params = new URLSearchParams({ SID: User.getSID() });
        const response = await axios.post(apiURL.users.logout, params);
        this.username = "";
        User.logout();
        this.$router.go();
      } catch (error) {
        ElMessage({
          type: "error",
          message: "Logout was not successful",
        });
      }
    },
    filterTeams() {
      // Filter for teams func
      const _input = this.teamSearch.input;
      if (_input == null || _input.trim() === "") {
        if (this.teamSearch.ownOnly) {
          this.teamSearch.filterOn = true;
          this.displayed.teamList = this.teamSearch.ownTeams.slice();
          return;
        }
        this.teamSearch.filterOn = false;
        this.displayed.teamList = this.teamList.slice();
        return;
      }

      this.displayed.teamList = this.displayed.teamList.filter((_t) => {
        return _t.teamName
          .toLowerCase()
          .match(new RegExp(_input.toLowerCase()));
      });
      this.teamSearch.filterOn = true;
    },
    filterPlayers() {
      // Filter for players
      const _input = this.playerSearch.input;
      if (_input == null || _input.trim() === "") {
        this.displayed.playerList = this.playerList.slice();
        this.playerSearch.filterOn = false;
        return;
      }

      this.displayed.playerList = this.displayed.playerList.filter((_p) => {
        return _p.username
          .toLowerCase()
          .match(new RegExp(_input.toLowerCase()));
      });
      this.playerSearch.filterOn = true;
    },
    showOwnTeams() {
      // Filter function for showing only own teams
      this.teamSearch.ownOnly = !this.teamSearch.ownOnly;
      if (this.teamSearch.ownOnly) {
        this.displayed.teamList = this.teamSearch.ownTeams.slice();
        this.teamSearch.filterOn = true;
      } else {
        this.displayed.teamList = this.teamList.slice();
      }
    },
    async fetchOwnTeams() {
      // fetching own teams by user id
      try {
        const idReqResponse = await axios.post(
          apiURL.users.getCurrentUser,
          new URLSearchParams({ SID: User.getSID() })
        );
        const userReqResponse = await axios.post(
          apiURL.users.getById,
          new URLSearchParams({ id: idReqResponse.data })
        );
        const _usr = plainToInstance(PlayerClass, userReqResponse.data);
        _usr.setTeamList();
        this.teamSearch.ownTeams = _usr.teamList;
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
  async created() {
    this.loading = true;
    await this.fetchTournaments();
    await this.fetchPlayers();
    this.displayed.playerList = this.playerList.slice();
    await this.fetchTeams();
    this.displayed.teamList = this.teamList.slice();
    this.getCurrentUser();
    if (this.username != undefined) {
      await this.fetchOwnTeams();
    }
    this.loading = false;
  },
};
</script>

<style scoped>
.main {
  height: 98vh;
}
.headerMain {
  height: 3%;
  display: flex;
  justify-content: space-between;
  padding-top: 1rem;
  margin-right: 1rem;
}

.headerInfos {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.listHeader {
  width: 50%;
}

.listHeaderSecond {
  width: 20%;
}

.headerSection {
  margin: 1rem;
}

.divMain {
  display: flex;
  flex-direction: column;
  justify-content: space-around;
  margin-inline: 1rem;
  height: 90%;
}

.listsWithHeaders {
  display: flex;
  flex-direction: row;
  justify-content: center;
  gap: 25px;
  height: 85%;
}

.listContent {
  height: 90%;
}

.routerLinks {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-top: 2rem;
}

.MainVueRouterLink {
  background-color: var(--color-ternary);
  color: var(--color-stroke);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  padding-block: 0.5rem;
  padding-inline: 1.5rem;
  text-decoration: none;
  text-align: center;
  margin-bottom: 0.5rem;
}

.authorizationRouteLinkers {
  color: white;
  margin: 1rem;
  text-align: center;
}

.logoutSec {
  cursor: pointer;
}

.usrIcon {
  margin-left: 2rem;
  width: 25px;
}

.hdr {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

.aa {
  margin-block: 0.81rem;
}

.aa :deep(.el-input-group__append) {
  padding: 5px;
}

.aa :deep(.el-checkbox) {
  --el-checkbox-checked-text-color: var(--color-own);
  --el-checkbox-checked-input-border-color: var(--color-own);
  --el-checkbox-checked-bg-color: var(--color-own);
  --el-checkbox-input-border-color-hover: var(--color-own);
}

.aa :deep(.el-input-group__prepend) {
  padding: 5px;
}
</style>
