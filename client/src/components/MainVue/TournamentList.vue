<!-- 
  Project: Studentske turnaje
  File: TournamentList.vue
  Created: 26.10.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Tournament list component
 -->

 <template>
  <div class="containerTournamentList">
    <header class="tournamentListHeader">
      <!-- Header list infos -->
      <label class="headerLabel">Name and game type</label>
      <label class="headerLabel">Expected start</label>
      <label class="headerLabel">Occupancy</label>
    </header>
    <main class="tournamentListMain">
      <!-- Iterate in passed list and show tournament list items -->
      <Tournament
        v-for="t in tournaments"
        :key="t.tnmntID"
        :tnmntID="t.tnmntID"
        :tnmntName="t.tnmntName"
        :game="t.gameType"
        :tnmntStart="t.getStart()"
        :participants="t.participantsCount"
        :maxParticipants="t.maxParticipants"
        :isApproved="t.isApproved"
        :approvalCallBack="reloadFun"
        @click="tournamentClick(t.tnmntID)"
      />
    </main>
  </div>
</template>

<script>
// Components
import Tournament from "./Tournament.vue";

export default {
  components: { Tournament },
  props: {
    tournaments: Array(),
    reloadFun: Function,
  },
  methods: {
    tournamentClick(_id) {
      // Redirect to the tournament detail
      this.$router.push({ name: "tournamentDetail", query: { id: _id } });
    },
  },
};
</script>

<style scoped>
.containerTournamentList {
  display: flex;
  flex-direction: column;
  gap: 5px;
}
.tournamentListHeader {
  background-color: var(--color-ternary);
  color: var(--color-stroke);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-inline: 3rem;
  padding-top: 0.2rem;
  padding-bottom: 0.2rem;
  height: 4%;
}
.tournamentListMain {
  background-color: var(--color-ternary);
  display: flex;
  flex-direction: column;
  overflow: auto;
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  height: 92%;
  padding-bottom: 1rem;
}
</style>