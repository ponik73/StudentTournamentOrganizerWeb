<!-- 
  Project: Studentske turnaje
  File: InfoTextWithLowOpacityComponent.vue
  Created: 20.11.2022
  Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz

  Description: Side info label with lower opacity
 -->

 <template>
    <div>
        <!-- Paragraph is showing passed message -->
        <p class="textField">{{ msg }}</p>
    </div>
</template>

<script>
    export default {
        props: {
            msg: ''
        }
    }
</script>

<style scoped>
.textField {
    opacity: 40%;
}
</style>