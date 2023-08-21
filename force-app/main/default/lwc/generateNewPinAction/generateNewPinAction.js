
import { api, LightningElement } from "lwc";
import generateNewPIN from "@salesforce/apex/GenerateNewPinController.generateNewPin";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { label } from "./labels.js";

export default class GenerateNewPinAction extends LightningElement {
    @api recordId;

    @api invoke() {
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
