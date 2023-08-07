<!-- 
  Project: Studentske turnaje
  File: ContentBoxList.vue
  Created: 11.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: List of players, teams or participants
 -->

 <template>
  <div>
    <div class="contentBoxList">
      <!-- Iterate in list and show items in list -->
      <ContentBox
        v-for="item in list"
        :key="item.id"
        :item="item"
        :canEdit="canEdit"
        :showDetail="showDetail"
      >
        <template #buttons="buttonProps">
          <!-- Sets buttons for each item -->
          <slot
            name="buttons"
            :id="getID(item)"
            :isOwn="buttonProps.isOwn"
          ></slot>
        </template>
      </ContentBox>
    </div>
  </div>
</template>

<script>
import IconCross from "../assets/icons/IconCross.vue";
import IconCheck from "../assets/icons/IconCheck.vue";

// Components
import ContentBox from "./ContentBoxList/ContentBox.vue";

// Classes
import PlayerClass from "../js/classes/PlayerClass";
import TeamClass from "../js/classes/TeamClass";
import ParticipantClass from "../js/classes/ParticipantClass";

export default {
  components: { IconCross, IconCheck, ContentBox },
  props: {
    list: { type: Array, required: true },
    canEdit: { type: Boolean, required: false },
    clickLinkName: { type: String, required: false },
    showDetail: { type: Boolean, required: false },
  },
  methods: {
    getLabel(_item) {
      // Gets object label according to the class
      switch (_item.constructor.name) {
        case PlayerClass.name:
          return _item.username;
        case TeamClass.name:
          return _item.teamName;
        case ParticipantClass.name:
          return _item.partName;
        default:
          return "";
      }
    },
    getID(_item) {
      // Gets object id according to the class
      switch (_item.constructor.name) {
        case PlayerClass.name:
          return _item.userID;
        case TeamClass.name:
          return _item.teamID;
        case ParticipantClass.name:
          return _item.idTP;
        default:
          return "";
      }
    },
    getRoute(_item) {
      // Gets redirect route according to the class
      switch (_item.constructor.name) {
        case PlayerClass.name:
          return "playerDetail";
        case TeamClass.name:
          return "teamDetail";
        default:
          return null;
      }
    },
    click(_item) {
      // If item could be redirected, redirect it to the detail page
      const _route = this.getRoute(_item);
      if (!_route) return;
      this.$router.push({
        name: _route,
        query: { id: this.getID(_item) },
      });
    },
  },
};
</script>

<style scoped>
.contentBoxList {
  background-color: var(--color-ternary);
  display: flex;
  flex-direction: column;
  overflow: auto;
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  height: 100%;
}
</style>