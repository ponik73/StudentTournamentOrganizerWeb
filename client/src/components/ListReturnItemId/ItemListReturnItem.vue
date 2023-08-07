<!-- 
  Project: Studentske turnaje
  File: ItemListReturnItem.vue
  Created: 21.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: List item for player, team or participant
 -->

 <template>
  <div
    class="contentBox"
    @click="$emit('selectedItem', item)"
    :style="{ 'background-color': setColor() }"
  >
    <div class="content">{{ getLabel(item) }}</div>
    <section class="buttons">
      <!-- Buttons delete, leave, approve, decline -->
      <ElTooltip
        effect="dark"
        :content="'Delete'"
        placement="top"
        :enterable="false"
      >
        <Delete
          v-if="couldDeleteFlag"
          class="smallBtnContentBox"
          @click.stop="$emit('itemForDelete', item)"
        />
      </ElTooltip>
      <ElTooltip
        effect="dark"
        :content="'Leave'"
        placement="top"
        :enterable="false"
      >
        <Remove
          v-if="couldLeaveFlag"
          class="smallBtnContentBox"
          @click.stop="$emit('itemForLeave', item)"
        />
      </ElTooltip>
      <ElTooltip
        effect="dark"
        :content="'Approve'"
        placement="top"
        :enterable="false"
      >
        <Check
          v-if="couldApprove()"
          class="smallBtnContentBox"
          @click.stop="$emit('itemForApprove', item)"
        />
      </ElTooltip>
      <ElTooltip
        effect="dark"
        :content="'Decline'"
        placement="top"
        :enterable="false"
      >
        <Close
          v-if="couldDecline()"
          class="smallBtnContentBox"
          @click.stop="$emit('itemForDecline', item)"
        />
      </ElTooltip>
    </section>
  </div>
</template>

<script>
import { Delete, Remove, Check, Close } from "@element-plus/icons-vue";
import User from "../../js/User";
import { ElTooltip } from "element-plus";

// Classes
import PlayerClass from "../../js/classes/PlayerClass";
import TeamClass from "../../js/classes/TeamClass";
import ParticipantClass from "../../js/classes/ParticipantClass";

export default {
  components: { Delete, Remove, Check, Close, ElTooltip },
  emits: [
    "selectedItem",
    "itemForDelete",
    "itemForLeave",
    "itemForApprove",
    "itemForDecline",
  ],
  props: ["item", "couldDelete", "leaderID", "teamID"],
  data() {
    return {
      couldDeleteFlag: false,
      couldLeaveFlag: false,
      isMatchFlag: false,
      isMatchFirst: true,
    };
  },
  methods: {
    getLabel(_item) {
      // Gets label according to the class
      switch (_item.constructor.name) {
        case PlayerClass.name:
          return _item.username;
        case TeamClass.name:
          return _item.teamName;
        case ParticipantClass.name:
          return _item.partName;
        default:
          return "Unknown class";
      }
    },
    setColor() {
      // Sets color according to class properties
      switch (this.item.constructor.name) {
        case PlayerClass.name:
          if (this.item.userID === this.leaderID) {
            return "var(--color-own)";
          }
          break;
        case TeamClass.name:
          if (User.getUserID() === this.item.leaderID) {
            return "var(--color-own)";
          }
          break;
        case ParticipantClass.name:
          if (this.item.isApproved === "0") {
            return "var(--color-unverified)";
          }
          break;
      }

      return "var(--color-secondary)";
    },
    couldApprove() {
      // Sets if user could approve object
      if (this.item.isApproved == "0") return true;

      return false;
    },
    couldDecline() {
      // Sets if user could decline object
      if (this.item.isApproved == "0") return true;

      return false;
    },
  },
  beforeMount() {
    this.couldLeaveFlag = false;
    this.couldDeleteFlag = this.couldDelete;
    switch (this.item.constructor.name) {
      case PlayerClass.name:
        if (this.item.userID === this.leaderID) {
          this.couldDeleteFlag = false;
        }
        break;
      case TeamClass.name:
        if (User.getUserID() === this.item.leaderID) {
          this.couldDeleteFlag = true;
        } else {
          this.couldLeaveFlag = true;
        }
        break;
    }
  },
};
</script>

<style scoped>
.contentBox {
  margin-left: 1rem;
  margin-right: 1rem;
  margin-top: 1rem;
  padding: 1rem;
  color: var(--color-ternary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  gap: 30px;
  cursor: pointer;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

.content {
  max-width: 90%;
}

.buttons {
  display: flex;
  flex-direction: row;
  gap: 5px;
}

.smallBtnContentBox {
  width: 1.5rem;
}
</style>