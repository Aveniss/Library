/**
 * Created by kamil on 07.07.2023.
 */

import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getLoans from "@salesforce/apex/ItemReturnPanelController.getLoans";
import updateLoans from "@salesforce/apex/ItemReturnPanelController.updateLoans";
import EmailLabel from "@salesforce/label/c.EmailLabel";
import EmailPlaceholder from "@salesforce/label/c.EmailPlaceholder";
import SelectStatusLabel from "@salesforce/label/c.SelectStatusLabel";
import SelectStatusPlaceholder from "@salesforce/label/c.SelectStatusPlaceholder";
import ItemTitle from "@salesforce/label/c.ItemTitle";
import ItemType from "@salesforce/label/c.ItemType";
import LoanEnd from "@salesforce/label/c.LoanEnd";
import LoanPenalty from "@salesforce/label/c.LoanPenalty";
import LoanStart from "@salesforce/label/c.LoanStart";

const SELECTED_DIV_STYLE =
  "selectedDiv enlarge-on-hover parent-div custom-box slds-box slds-p-around_small slds-text-align_center";
const UNSELECTED_DIV_STYLE =
  "unselectedDiv enlarge-on-hover parent-div custom-box slds-box slds-p-around_small slds-text-align_center";
const DELAY = "Delay";
const BORROWED = "Borrowed";
const RESERVATION = "Reservation";
const RETURNED = "Returned";
const ALL = "All";

export default class ItemReturnPanel extends LightningElement {
  allLoans = [];

  loanStatus = ALL;
  email = "";
  numberOfSelectedLoans = 0;

  label = {
    EmailLabel,
    EmailPlaceholder,
    SelectStatusLabel,
    SelectStatusPlaceholder,
    ItemTitle,
    ItemType,
    LoanEnd,
    LoanPenalty,
    LoanStart
  };

  get filteredLoans() {
    return this.allLoans
      .map((element) => ({
        ...element,
        Style: element.Selected ? SELECTED_DIV_STYLE : UNSELECTED_DIV_STYLE
      }))
      .filter(
        (element) =>
          element.Status__c === this.loanStatus || this.loanStatus === ALL
      );
  }

  get getNumberOfSelectedLoans() {
    return this.allLoans.filter((element) => element.Selected).length;
  }

  get options() {
    return [
      { label: ALL, value: ALL },
      { label: RESERVATION, value: RESERVATION },
      {
        label: BORROWED,
        value: BORROWED
      },
      { label: RETURNED, value: RETURNED },
      { label: DELAY, value: DELAY }
    ];
  }

  handleChangeStatus(event) {
    this.loanStatus = event.detail.value;
    if (this.allLoans.length === 0) {
      this.loadData();
    }
  }

  handleChangeEmail(event) {
    this.email = event.detail.value;
  }

  loadData() {
    this.allLoans.length = 0;
    getLoans({ email: this.email, status: ALL })
      .then((result) => {
        this.allLoans = result.map((element) => ({
          ...element,
          Selected: false
        }));
      })
      .catch((downloadError) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Data Download Failed",
            message: downloadError.message,
            variant: "error"
          })
        );
      });
  }

  updateItemsStatus() {
    let selectedLoans = this.allLoans.filter((element) => element.Selected);

    updateLoans({ loans: selectedLoans })
      .then(() => {
        // eslint-disable-next-line no-restricted-globals
        location.reload();
      })
      .catch((udateError) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Data Update Failed",
            message: udateError.body.message,
            variant: "error"
          })
        );
      });
  }

  selectItem(event) {
    if (this.loanStatus === DELAY || this.loanStatus === BORROWED) {
      const passedData = event.target.dataset.id;
      let loan = this.allLoans.find((element) => element.Id === passedData);

      loan.Selected = !loan.Selected;
      this.allLoans = this.allLoans.map((element) => ({ ...element }));
    }
  }
}
