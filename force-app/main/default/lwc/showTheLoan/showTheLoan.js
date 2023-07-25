/**
 * Created by kamil on 07.07.2023.
 */

import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getLoans from "@salesforce/apex/ShowTheLoanController.getLoans";
import updateLoans from "@salesforce/apex/ShowTheLoanController.updateLoans";
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

export default class ShowTheLoan extends LightningElement {
  // eslint-disable-next-line @lwc/lwc/no-document-query
  _filteredLoans = [];
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
    return this._filteredLoans;
  }

  get getNumberOfSelectedLoans() {
    return this.numberOfSelectedLoans;
  }

  get options() {
    return [
      { label: ALL, value: ALL },
      { label: RESERVATION, value: RESERVATION },
      { label: BORROWED, value: BORROWED },
      { label: RETURNED, value: RETURNED },
      { label: DELAY, value: DELAY }
    ];
  }

  handleChangeStatus(event) {
    this.loanStatus = event.detail.value;
    if (this.allLoans.length === 0) {
      this.loadData();
    }
    this.filterData();
  }

  handleChangeEmail(event) {
    this.email = event.detail.value;
  }

  filterData() {
    this._filteredLoans.length = 0;
    this._filteredLoans = this.allLoans.filter((element) => {
      return element.Status__c === this.loanStatus || this.loanStatus === ALL;
    });
  }

  loadData() {
    this.allLoans.length = 0;
    getLoans({ email: this.email, status: ALL })
      .then((result) => {
        let key = 0;
        result.forEach((element) => {
          let newElement = JSON.parse(JSON.stringify(element));
          newElement.Selected = false;
          newElement.Key = key;
          newElement.Style = UNSELECTED_DIV_STYLE;
          this.allLoans.push(newElement);
          key += 1;
        });
        this.filterData();
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Data Download Failed",
            message: error.message,
            variant: "error"
          })
        );
      });
  }

  updateItemsStatus() {
    let selectedLoans = this.allLoans.filter((element) => {
      return element.Selected;
    });

    updateLoans({ loans: selectedLoans });

    this._filteredLoans.length = 0;
    this.allLoans.length = 0;

    // eslint-disable-next-line no-restricted-globals
    location.reload();
  }

  selectItem(event) {
    if (this.loanStatus === DELAY || this.loanStatus === BORROWED) {
      const passedData = event.target.dataset.id;
      const div = this.template.querySelector(`div[data-id="${passedData}"]`);
      const divID = Number(div.id.split("-")[0]);
      let loan = this.allLoans.filter((element) => {
        return element.Key === divID;
      })[0];

      if (loan.Selected) {
        loan.Style = UNSELECTED_DIV_STYLE;
        this.numberOfSelectedLoans -= 1;
      } else {
        loan.Style = SELECTED_DIV_STYLE;
        this.numberOfSelectedLoans += 1;
      }
      loan.Selected = !loan.Selected;
    }
  }
}
