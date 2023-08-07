<!-- 
  Project: Studentske turnaje
  File: ListReturnItem.vue
  Created: 21.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: List for players, teams or participants
 -->

 <template>
  <div class="contentBoxList">
    <!-- Iterate in list of objects and creates list items -->
    <ListItem
      v-for="item in list"
      :key="item.id"
      :item="item"
      :couldDelete="this.couldDelete"
      :leaderID="this.leaderID"
      :teamID="this.teamID"
      @selectedItem="click"
      @itemForDelete="clickDelete"
      @itemForLeave="clickLeave"
      @itemForApprove="clickApprove"
      @itemForDecline="clickDecline"
    />
  </div>
</template>
  
<script>
import ListItem from "./ItemListReturnItem.vue";

export default {
  emits: [
    "selectedItem",
    "itemForDelete",
    "itemForLeave",
    "itemForApprove",
    "itemForDecline",
  ],
  components: { ListItem },
  props: {
    list: { type: Array, required: true },
    couldDelete: false,
    leaderID: Int32Array,
    teamID: Int32Array,
  },
  methods: {
    // Component is just emitting selection on items by user to the parent class
    click(_item) {
      this.$emit("selectedItem", _item);
    },
    clickDelete(_item) {
      this.$emit("itemForDelete", _item);
    },
    clickLeave(_item) {
      this.$emit("itemForLeave", _item);
    },
    clickApprove(_item) {
      this.$emit("itemForApprove", _item);
    },
    clickDecline(_item) {
      this.$emit("itemForDecline", _item);
    },
  },
};
</script>
  
<style scoped>
.contentBoxList {
  background-color: var(--color-primary);
  display: flex;
  flex-direction: column;
  overflow: auto;
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  height: 95%;
  font-family: var(--font-family-primary);
  font-size: large;
  padding-bottom: 1rem;
}
</style>