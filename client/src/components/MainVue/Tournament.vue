<!-- 
  Project: Studentske turnaje
  File: Tournament.vue
  Created: 26.10.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Tournament list item
 -->

 <template>
  <div class="divItem">
    <div class="divButtons" v-show="edit">
      <!-- Approve tournament button -->
      <ElTooltip
        class="box-item"
        effect="dark"
        content="Approve tournament"
        placement="top"
        :enterable="false"
      >
        <IconCheck class="btnApprove" @click.stop="approveTournament" />
      </ElTooltip>
      <!-- Cancel tournament button -->
      <ElTooltip
        class="box-item"
        effect="dark"
        content="Cancel tournament"
        placement="bottom"
        :enterable="false"
      >
        <IconCross class="btnDisprove" @click.stop="cancelTournament" />
      </ElTooltip>
    </div>
    <!-- Info about tournament item -->
    <div class="divTournament">
      <label class="lblTnmntName">{{ tnmntName }}</label>
      <label class="lblGame">{{ game }}</label>
      <label class="lblTnmntStart">{{ tnmntStart }}</label>
      <label class="lblOccupancy">{{ occupancy }}</label>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { ElMessageBox, ElTooltip } from "element-plus";
import IconCheck from "../../assets/icons/IconCheck.vue";
import IconCross from "../../assets/icons/IconCross.vue";
import apiURL from "../../js/apiURL";
import User from "../../js/User";

export default {
  components: { IconCross, IconCheck, ElTooltip },
  props: {
    tnmntID: String,
    tnmntName: String,
    game: String,
    tnmntStart: String,
    participants: String,
    maxParticipants: String,
    isApproved: false,
    approvalCallBack: Function,
  },
  data() {
    return {
      occupancy: this.participants + " / " + this.maxParticipants,
      edit: false,
      color: "var(--color-secondary)",
    };
  },
  methods: {
    async tournamentApproval(approve, alertProps) {
      // Tournament approval button clicked function
      const paramObj = Boolean(approve)
        ? { id: this.tnmntID }
        : { id: this.tnmntID };
      const params = new URLSearchParams(paramObj);
      const url = Boolean(approve)
        ? apiURL.tournaments.approve
        : apiURL.tournaments.remove;
      try {
        const response = await axios.post(url, params);
        if (response.status != 200) {
          ElMessageBox.alert(
            "Error occured during tournament approval. Please try again",
            "Error occured",
            {
              showClose: false,
              type: "error",
              customStyle: "--el-messagebox-title-color: var(--color-red)",
              confirmButtonText: "OK",
              callback: this.approvalCallBack,
            }
          );
        } else {
          this.approvalCallBack();
          ElMessageBox.alert(alertProps.title, alertProps.mess, {
            showClose: false,
            confirmButtonText: "OK",
          });
        }
      } catch (error) {
        console.error(error);
      }
    },
    async approveTournament() {
      // Approve tournament and call function for approve with true value
      const alertProps = {
        mess: "Tournament has been approved",
        title: `Tournament ${this.tnmntName} starting on ${this.tnmntStart} was approved!`,
      };
      await this.tournamentApproval(true, alertProps);
    },
    async cancelTournament() {
      // Decline tournament and call function for approve with false value
      const alertProps = {
        mess: "Tournament has been cancelled",
        title: `Tournament ${this.tnmntName} starting on ${this.tnmntStart} was cancelled and will be removed!`,
      };
      await this.tournamentApproval(false, alertProps);
    },
  },
  mounted() {
    this.color = Number(this.isApproved)
      ? "var(--color-secondary)"
      : "var(--color-red)";
    this.edit = User.isAdmin() && !Number(this.isApproved);
  },
  created() {
    this.edit = User.isAdmin() && !Number(this.isApproved);
    this.color = Number(this.isApproved)
      ? "var(--color-secondary)"
      : "var(--color-red)";
  },
};
</script>

<style scoped>
.divItem {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  background-color: v-bind("color");
  color: var(--color-ternary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  margin-inline: 1rem;
  margin-top: 1rem;
  padding: 1rem;
}
.divButtons {
  display: flex;
  flex-direction: column;
}
.btnApprove {
  margin-bottom: 0.2rem;
}

.divTournament {
  display: grid;
  grid-template-columns: 1.5fr 1.3fr 0.7fr;
  grid-template-rows: 1fr 1fr;
  cursor: pointer;
  width: 100%;
  /* margin-right: 1rem; */
}
.lblTnmntName {
  grid-column: 1;
  grid-row: 1;
  margin: 0.25rem;
  cursor: inherit;
}
.lblGame {
  grid-column: 1;
  grid-row: 2;
  margin: 0.25rem;
  cursor: inherit;
}
.lblTnmntStart {
  grid-column: 2;
  grid-row: 1 / span 2;
  margin: 1rem;
  cursor: inherit;
}
.lblOccupancy {
  grid-column: 3;
  grid-row: 1 / span 2;
  align-items: center;
  text-align: right;
  margin-top: 1rem;
  margin-bottom: 1rem;
  cursor: inherit;
}
</style>