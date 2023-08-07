<!-- 
  Project: Studentske turnaje
  File: MatchesList.vue
  Created: 22.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: List of matches
 -->

 <template>
  <div class="mainMatchesList">
    <ListItem
      v-for="item in list"
      :match="item"
      :key="item.id"
      @selectedItem="selectedItemClick"
    />
  </div>
</template>

<script>
import ListItem from "../MatchItemComponent.vue";

export default {
  emits: ["selectedItem"],
  components: { ListItem },
  props: {
    list: { type: Array, required: true },
  },
  methods: {
    selectedItemClick(_item) {
      // On item click, emit it to the parent
      this.$emit("selectedItem", _item);
    },
  },
};
</script>

<style scoped>
.mainMatchesList {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  background: var(--color-primary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  padding: 1rem;
  height: 100%;
  overflow-x: hidden;
}
</style>