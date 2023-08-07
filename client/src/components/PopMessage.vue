<!-- 
  Project: Studentske turnaje
  File: PopMessage.vue
  Created: 9.11.2022
  Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz

  Description: Pop message component
 -->

 <template>
  <Transition name="modal">
    <div v-if="show" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <div class="modal-header">
            {{ header }}
          </div>

          <div class="modal-body">
            {{ body }}
          </div>

          <div class="modal-footer">
            <button class="modal-default-button" @click="$emit('close')">
              OK
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script>
export default {
  props: {
    show: Boolean,
    header: String,
    body: String,
    warning: Boolean,
  },
  data() {
    return {
      headerColor: "var(--color-secondary)",
    };
  },
  watch: {
    warning(n, o) {
      this.headerColor = n ? "var(--color-red)" : "var(--color-secondary)";
    },
  },
};
</script>

<style>
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: table;
  transition: opacity 0.3s ease;
}

.modal-wrapper {
  display: table-cell;
  vertical-align: middle;
}

.modal-container {
  width: 30%;
  margin: 0px auto;
  padding: 2rem 2rem;
  border-radius: 2px;
  box-shadow: 0 2px 8px var(--color-stroke);
  transition: all 0.3s ease;
  color: var(--color-ternary);
  display: flex;
  flex-direction: column;
  align-items: center;
  opacity: 1;
}

.modal-header {
  color: v-bind("headerColor");
  font-size: larger;
}

.modal-body {
  margin: 1.5rem 0;
}

.modal-default-button {
  padding-inline: 1.5rem;
  padding-block: 0.5rem;
  color: var(--color-stroke);
  background-color: var(--color-secondary);
  border: var(--style-border);
  border-radius: var(--style-border-radius);
}

.modal-enter-from {
  opacity: 1;
}

.modal-leave-to {
  opacity: 1;
}

.modal-enter-from .modal-container,
.modal-leave-to .modal-container {
  -webkit-transform: scale(1.1);
  transform: scale(1.1);
}
</style>