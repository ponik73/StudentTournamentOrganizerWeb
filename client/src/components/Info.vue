<!-- 
  Project: Studentske turnaje
  File: Info.vue
  Created: 4.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Labels of infos passed in the list
 -->

 <template>
  <div>
    <table class="tableInfo">
      <!-- Iterate in list items and shows them as the table -->
      <tr v-for="i in infos" :key="i">
        <!-- Item label -->
        <td class="colOne">{{ i.label }}:</td>
        <!-- Item content -->
        <td class="colTwo">
          <strong>{{ i.data }}</strong>
        </td>
      </tr>
    </table>
  </div>
</template>

<script>
export default {
  props: {
    infos: { type: Array, required: true },
  },
};
</script>

<style scoped>
.colOne {
  padding: 0.5rem;
}
.colTwo {
  padding-left: 2rem;
}
.tableInfo {
  margin-left: 3rem;
}
</style>