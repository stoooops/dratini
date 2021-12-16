<!-- UserInput.vue -->
<!-- Based on https://www.thisdot.co/blog/vue-3-2-using-composition-api-with-script-setup -->
<template>
  <div>Hello, {{ name }}!</div>
  <Form v-model="name" @submit="submitForm" />
</template>

<script lang="ts" setup>
import { ref } from "vue";
import Form from "../components/Form.vue";

const name = ref("");

function submitForm() {
  console.log(name.value);
}
</script>
