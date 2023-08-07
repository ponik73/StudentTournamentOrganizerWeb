<!-- 
  Project: Studentske turnaje
  File: ContentBox.vue
  Created: 11.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: List item for player, team or participant
 -->

 <template>
  <div
    @click="click(item)"
    :class="[
      'contentBox',
      isApproved(item) ? '' : 'notApproved',
      isOwn(item) ? 'own' : '',
    ]"
  >
    <!-- Object name -->
    <label class="content">{{ getLabel(item) }}</label>

    <!-- Buttons showing on item -->
    <div class="editButtons" v-show="canEdit">
      <slot name="buttons" :isOwn="isOwn(item)"> </slot>
    </div>
  </div>
</template>

<script>
import IconCross from "../../assets/icons/IconCross.vue";
import IconCheck from "../../assets/icons/IconCheck.vue";
import User from "../../js/User";
import { ElMessage } from "element-plus";
import axios from "axios";
import apiURL from "../../js/apiURL";
import { plainToInstance } from "class-transformer";
import ErrorMessageConverter from "../../js/ErrorMessageConverter";

// Classes
import ParticipantClass from "../../js/classes/ParticipantClass";
import PlayerClass from "../../js/classes/PlayerClass";
import TeamClass from "../../js/classes/TeamClass";

export default {
  components: { IconCross, IconCheck },
  props: ["item", "canEdit", "showDetail"],
  data() {
    return {
      isInTeam: false,
    };
  },
  methods: {
    //#region API
    async isCurrentUserInTeam(_id) {
      // Checks if current user is in team
      let _teamMembers = Array();
      try {
        const response = await axios.post(
          apiURL.teams.getTeamPlayers,
          new URLSearchParams({ teamID: _id })
        );
        response.data.forEach((e) => {
          _teamMembers.push(plainToInstance(PlayerClass, e));
        });
        this.isInTeam =
          _teamMembers.find((_p) => {
            return _p.userID === User.getUserID();
          }) != undefined;
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
    //#endregion
    getLabel(_item) {
      // Sets label according to object
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
          if (_item.teamID) return _item.teamID;
          else return _item.userID;
        default:
          return "";
      }
    },
    getRoute(_item) {
      // Gets route according to the class
      switch (_item.constructor.name) {
        case PlayerClass.name:
          return "playerDetail";
        case TeamClass.name:
          return "teamDetail";
        case ParticipantClass.name:
          if (_item.teamID) return "teamDetail";
          else return "playerDetail";
        default:
          return null;
      }
    },
    click(_item) {
      // On click route to the detail
      if (!this.showDetail) return;
      const _route = this.getRoute(_item);
      if (!_route) return;
      this.$router.push({
        name: _route,
        query: { id: this.getID(_item) },
      });
    },
    isApproved(_item) {
      // Checks if object is approved due to approving by leader
      if (!User.getUsername()) return true;
      switch (_item.constructor.name) {
        case PlayerClass.name:
          return true;
        case TeamClass.name:
          return true;
        case ParticipantClass.name:
          return _item.isApproved === "1";
        default:
          return null;
      }
    },
    isOwn(_item) {
      // Checks if current user has any relationship with object according to the class
      switch (_item.constructor.name) {
        case PlayerClass.name:
          return _item.userID === User.getUserID();
        case TeamClass.name:
          return this.isInTeam;
        case ParticipantClass.name:
          if (_item.userID) return _item.userID === User.getUserID();
          return this.isInTeam;
        default:
          return null;
      }
    },
    async setOwnClass() {
      // Sets own class
      if (!User.getUsername()) return;
      switch (this.item.constructor.name) {
        case TeamClass.name:
          await this.isCurrentUserInTeam(this.item.teamID);
          break;
        case ParticipantClass.name:
          if (this.item.teamID)
            await this.isCurrentUserInTeam(this.item.teamID);
          break;
        default:
          break;
      }
    },
  },
  async beforeMount() {
    await this.setOwnClass();
  },
  async beforeUpdate() {
    await this.setOwnClass();
  },
};
</script>

<style scoped>
.contentBox {
  margin-left: 1rem;
  margin-right: 1rem;
  margin-top: 1rem;
  padding: 1rem;
  gap: 3rem;
  color: var(--color-ternary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  background-color: var(--color-secondary);
  cursor: pointer;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}
.contentBox:last-child {
  margin-bottom: 1rem;
}
.content {
  cursor: inherit;
  max-width: 70%;
}
.editButtons {
  display: flex;
  flex-direction: row;
  gap: 0.5rem;
}
.notApproved {
  background-color: var(--color-red);
}
.own {
  background-color: var(--color-own);
}
</style>