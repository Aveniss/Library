/**
 * Created by kamil on 03.08.2023.
 */

import { api, LightningElement } from "lwc";
import generateNewPIN from "@salesforce/apex/GenerateNewPinController.generateNewPin";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { label } from "./labels.js";

export default class GenerateNewPin extends LightningElement {
  @api recordId;
  myLabel = label;

  handleClickButton() {
    generateNewPIN({ personId: this.recordId })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: label.SuccessfullyGeneratePinLabel,
            variant: "success"
          })
        );
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: label.GenerateNewPinError,
            message: error.message,
            variant: "error"
          })
        );
      });
  }
}
