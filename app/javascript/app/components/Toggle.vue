<template>
  <div class="pic-it-toggle" :class="toggleClasses">
    <div class="pic-it-toggle__button">
      <input
        class="pic-it-toggle__input"
        type="checkbox"
        :disabled="disabled"
        v-model="toggleValue"
        @change="onChange"
        :id="id"
      />
      <label class="pic-it-toggle__label" @click="onToggle">
        <span>{{ label }}</span>
      </label>
    </div>
  </div>
</template>

<script>
export default {
  name: "toggle",
  data() {
    return {};
  },
  computed: {
    toggleClasses() {
      return {
        "pic-it-toggle--label": this.label,
        "is-disabled": this.disabled,
        "is-checked": this.value
      };
    },
    toggleValue: {
      get() {
        return this.value;
      },
      set(newValue) {
        return newValue;
      }
    }
  },
  props: {
    /**
     * Set value with <code>v-model</code> prop
     */
    value: {
      type: Boolean,
      required: true
    },
    /**
     * Label text
     */
    label: {
      type: String,
      required: false,
      default: null
    },
    /**
     * Disable toggle
     */
    disabled: {
      type: Boolean,
      required: false,
      default: false
    },
    /**
     * Set id to input
     */
    id: {
      type: String,
      required: false,
      default: null
    },
  },
  methods: {
    onChange(event) {
      /**
       * Passthrough <code>input</code> event
       * @type {Event}
       */
      this.$emit("input", event.target.checked);
    },
    onToggle() {
      if (!this.disabled) {
        this.$emit("input", !this.toggleValue);
      }
    }
  }
};
</script>