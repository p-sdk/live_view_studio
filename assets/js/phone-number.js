import { AsYouType } from "libphonenumber-js";

const PhoneNumber = {
  mounted() {
    this.el.addEventListener("input", e => {
      this.el.value = new AsYouType("US").input(this.el.value);
    });
  }
};

export default PhoneNumber;
