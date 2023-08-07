<!-- 
  Project: Studentske turnaje
  File: MatchList.vue
  Created: 22.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: List of matches
 -->

 <template>
    <div class="mainMatchList">
        <!-- Iterate in passed list and create list items -->
        <MatchListItem
            v-for="item in list"
            :key="list.indexOf(item)"
            :item="item"
            :isSelected="activeIndex"
            />
    </div>
</template>

<script>
    import MatchListItem from "./MatchListItem.vue";

    export default {
        components:
        {
            MatchListItem,
        },
        props:
        {
            list: { type: Array, required: true },
            activeIndex: Number
        },
    }
</script>

<style scoped>

.mainMatchList {
    display: flex;
    flex-direction: column;
    height: 95%;
    overflow: auto;
}

</style>