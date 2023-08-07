<!-- 
  Project: Studentske turnaje
  File: TeamDetail.vue
  Created: 1.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Team detail page
 -->

 <template>
  <div class="TeamDetail">
    <section class="headSec">
      <!-- Page header and pen icon for editing team -->
      <DetailHeading :headingText="headingText" class="detailHeading" />
      <EditPen v-if="isLeader" class="editPen" @click="routeManageTeams" />
    </section>
    <body class="bodyTeamDetail">
      <div class="infoAndListPlayers">
        <section>
          <!-- Team info with available statistics -->
          <Info :infos="infos" />
          <section v-show="team.logoUrl" class="teamLogoSec">
            <!-- Team logo -->
            <h2>Team logo:</h2>
            <img class="image" :src="this.team.logoUrl" alt="Team logo" />
          </section>
        </section>
        <section>
          <!-- List of team's members -->
          <h2>Team's members</h2>
          <ContentBoxList
            class="playersList"
            :list="players"
            :header="'Team players'"
            :canEdit="true"
            :showDetail="true"
          />
        </section>
      </div>
    </body>
  </div>
</template>

<script>
import apiURL from "../js/apiURL";
import axios from "axios";
import IconArrowBack from "../assets/icons/IconArrowBack.vue";
import { plainToInstance } from "class-transformer";
import { EditPen } from "@element-plus/icons-vue";
import User from "../js/User";

// Components
import Info from "../components/Info.vue";
import DetailHeading from "../components/DetailHeading.vue";
import ContentBoxList from "../components/ContentBoxList.vue";

// Classes
import TeamClass from "../js/classes/TeamClass";
import PlayerClass from "../js/classes/PlayerClass";

export default {
  components: { Info, IconArrowBack, DetailHeading, ContentBoxList, EditPen },
  data() {
    return {
      team: TeamClass,
      infos: Array(),
      headingText: "Team detail",
      players: Array(),
      isLeader: false,
    };
  },
  props: {
    id: { type: String, required: true },
  },
  methods: {
    async fetchTeamData() {
      // Fetch current team data
      try {
        const params = new URLSearchParams({ id: this.id });
        const response = await axios.post(apiURL.teams.getById, params);
        this.team = plainToInstance(TeamClass, response.data);
        this.makeInfos();
      } catch (error) {
        console.error(error);
      }
    },
    async fetchTeamPlayers() {
      // Fetch list of team players
      try {
        const params = new URLSearchParams({ teamID: this.id });
        const response = await axios.post(apiURL.teams.getTeamPlayers, params);
        if (response.data.length < 1) return;

        response.data.forEach((element) => {
          if (element.userID == User.getUserID()) this.isLeader = true;
          element.isApproved = true;
          this.players.push(plainToInstance(PlayerClass, element));
        });
      } catch (error) {}
    },
    routeManageTeams() {
      // Redirect to manage teams page
      this.$router.replace({
        name: "myTeams",
      });
    },
    makeInfos() {
      // Creates list of infos
      this.infos = this.team.TransformToInfos();
    },
  },
  created() {
    this.fetchTeamData();
    this.fetchTeamPlayers();
  },
};
</script>

<style  scoped>
.TeamDetail {
  height: 98vh;
}
.detailHeading {
  height: 9%;
}

.headSec {
  display: flex;
  justify-content: space-between;
  margin-right: 2rem;
}

.bodyTeamDetail {
  display: flex;
  flex-direction: column;
  justify-content: start;
  align-items: baseline;
  height: 91%;
}
.btnDivTeamDetail {
  margin-top: 3rem;
  padding-left: 2.5rem;
  justify-content: flex-start;
}
.playersList {
  margin-right: 10rem;
  width: 25rem;
  height: 25rem;
}
.infoAndListPlayers {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  width: 100%;
  height: 100%;
}

.editPen {
  width: 2rem;
  cursor: pointer;
}

.teamLogoSec {
  padding-top: 2rem;
  margin-left: 3rem;
  height: 50%;
}

.image {
  height: 100%;
  border: var(--style-border);
  border-radius: var(--style-border-radius);
}
</style>