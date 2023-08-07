<!-- 
  Project: Studentske turnaje
  File: MatchListItem.vue
  Created: 22.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: List item of matches list, this component is used in generating tournament manually
 -->

 <template>
  <div class="mainMatchItem">
    <!-- Showing both participants names, if participant is not selected yet, still on position is hidden char because of css -->
    <section>
      <p class="partName">&nbsp;{{ item.partOneName }}</p>
    </section>
    <!-- Line for divide component to two visual parts -->
    <hr
      style="
        display: block;
        width: 90%;
        height: 0.1px;
        text-align: center;
        background-color: white;
        color: white;
      "
    />
    <section>
      <p class="partName">&nbsp;{{ item.partTwoName }}</p>
    </section>
  </div>
</template>

<script>
export default {
  props: ["key", "item", "isSelected"],
  methods: {
    data() {
      return {
        isSelectedOne: false,
        isSelectedTwo: false,
      };
    },
    created() {
      // Sets component selection
      if (this.isSelected === "0") {
        isSelectedOne = true;
      } else if (this.isSelected === "1") {
        isSelectedTwo = true;
      }
    },
  },
};
</script>

<style scoped>
.mainMatchItem {
  display: flex;
  flex-direction: column;
  justify-content: center;
  background: var(--color-secondary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  margin: 0.4rem;
  padding: 0.2rem;
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  height: 5rem;
}

.partName {
  padding: 0;
  margin: 0;
  margin-left: 1rem;
}
</style>