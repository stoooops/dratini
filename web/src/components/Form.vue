<!-- Form.vue -->
<!-- Based on https://www.thisdot.co/blog/vue-3-2-using-composition-api-with-script-setup -->
<template>
  <form @submit.prevent="submitHandler">
    <label
      >Name
      <input v-model="name" type="text" />
    </label>
    <button>Submit</button>
  </form>
</template>

<script lang="ts" setup>
import { computed, defineProps, defineEmits } from "vue";
const props = defineProps({
  modelValue: {
    type: String,
    default: "",
  },
});
const emit = defineEmits(["update:modelValue", "submit"]);

const name = computed({
  get() {
    return props.modelValue;
  },
  set(val) {
    emit("update:modelValue", val);
  },
});

function submitHandler() {
  emit("submit");
}
</script>
