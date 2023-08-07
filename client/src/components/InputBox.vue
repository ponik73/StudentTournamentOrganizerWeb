<!-- 
  Project: Studentske turnaje
  File: InputBox.vue
  Created: 13.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Input box component
 -->

 <template>
  <div class="InputBoxContainer">
    <label class="labelInputBox">{{ label }}</label>
    <slot name="input"> </slot>
    <slot name="message"> </slot>
  </div>
</template>

<script>
export default {
  props: ["label"],
};
</script>

<style scoped>
.InputBoxContainer {
  border: var(--style-border);
  border-radius: var(--style-border-radius);
  display: flex;
  flex-direction: column;
  justify-content: space-around;
  background-color: var(--color-secondary);
  padding: 0.5rem;
  width: 80%;
  max-height: 9rem;
}
.labelInputBox {
  font-size: large;
  width: 100%;
  margin-bottom: 10%;
}
</style>