<!-- 
  Project: Studentske turnaje
  File: BracketComponent.vue
  Created: 24.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Bracket of the tournament
 -->

 <template>
  <div>
    <section class="tnmntAllRounds">
      <!-- Iterate in tournaments rounds and create lists for them -->
      <section class="tnmntRound" v-for="index in rounds" :key="index">
        <p class="roundLabel">{{ getRoundAsString(index) }}</p>
        <!-- Gap is settled according to the current round for visualing bracket -->
        <section class="matchesList" :style="{ gap: getGap(index) }">
          <!-- Iterate in matches for current round add fill list with them -->
          <MatchItem
            v-for="item in getRoundMatches(index)"
            :key="item.id"
            :match="item"
            @selectedItem="selectedItemClick"
          />
        </section>
      </section>
    </section>
  </div>
</template>

<script>
import MatchItem from "./MatchItemComponent.vue";

export default {
  emits: ["selectedItem"],
  components: {
    MatchItem,
  },
  props: {
    matches: { type: Array(), required: true },
  },
  data() {
    return {
      localMatches: Array(),
      rounds: Number,
      gapValue: 0.5,
    };
  },
  methods: {
    getMaxTnmntRound() {
      // Gets tournament max round
      var maxRound = 0;

      this.localMatches.forEach((element) => {
        if (Number(element.tnmntRound) > maxRound) {
          maxRound = Number(element.tnmntRound);
        }
      });

      return maxRound;
    },
    getTnmntsRoundCount(tnmntRound) {
      // Gets number of rounds in the tournament
      var res = 0;
      while (tnmntRound >= 1) {
        tnmntRound /= 2;
        res++;
      }

      return res;
    },
    getRoundAsString(roundIndex) {
      // Transforms round to the string as round name
      var round = this.getRoundFromIndex(roundIndex);
      switch (round) {
        case 1:
          return "Final";
        case 2:
          return "Semifinal";
        case 4:
          return "Quaterfinal";
        case 8:
          return "Eighth-final";
      }

      return round + "th-final";
    },
    getRoundMatches(roundIndex) {
      // Gets all round matches from tournament
      var round = this.getRoundFromIndex(roundIndex);
      var resMatches = Array();
      this.matches.forEach((element) => {
        if (Number(element.tnmntRound) === round) {
          resMatches.push(element);
        }
      });

      return resMatches;
    },
    getRoundFromIndex(roundIndex) {
      // Transforms round index to the round number
      // e.g. fourth round in the tournament has index 3, but its round number is 8 (first -> 1, second -> 2, third -> 4, fourth -> 8)
      return Math.pow(2, roundIndex) / 2;
    },
    getGap(roundIndex) {
      // Getting gap between matches according to the round index
      var maxRound = this.getMaxTnmntRound();

      var currentRound = this.getRoundFromIndex(roundIndex);

      var result =
        String(
          0.5 * (maxRound / currentRound) + (maxRound / currentRound - 1) * 6
        ) + "rem";
      return result;
    },
    selectedItemClick(_item) {
      // Emit selected item back to the parent
      this.$emit("selectedItem", _item);
    },
  },
  created() {
    this.localMatches = this.matches;
    var maxRound = this.getMaxTnmntRound();
    this.rounds = this.getTnmntsRoundCount(maxRound);
  },
};
</script>

<style scoped>
.tnmntAllRounds {
  display: flex;
  flex-direction: row-reverse;
  justify-content: center;
  margin-inline: 3rem;
  gap: 25px;
}
.tnmntRound {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.roundLabel {
  background: var(--color-ternary);
  color: black;
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  padding: 0.5rem;
  position: fixed;
}
.matchesList {
  display: flex;
  flex-direction: column;
  justify-content: center;
  margin-top: 4rem;
  height: 99%;
}
</style>