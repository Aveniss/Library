/**
 * Created by kamil on 07.07.2023.
 */

import { LightningElement, track } from "lwc";
import getLoans from "@salesforce/apex/ShowTheLoanController.getLoans";
import updateLoans from "@salesforce/apex/ShowTheLoanController.updateLoans";

export default class ShowTheLoan extends LightningElement {
  // eslint-disable-next-line @lwc/lwc/no-document-query
  @track columns = [];
  @track allItems = [];
  @track selectedDivs = [];

  checkedDiv = "rgb(40, 128, 247)";
  unCheckedDiv = "rgb(244, 246, 249)";

  value = "";
  email = "";

  get options() {
    return [
      { label: "All", value: "All" },
      { label: "Reservation", value: "Reservation" },
      { label: "Borrowed", value: "Borrowed" },
      { label: "Returned", value: "Returned" },
      { label: "Delay", value: "Delay" }
    ];
  }

  handleChange(event) {
    this.selectedDivs.forEach((divId) => {
      const div = this.template.querySelector(`div[data-id="${divId}"]`);
      div.style.backgroundColor = this.unCheckedDiv;
    });
    this.selectedDivs.length = 0;
    this.value = event.detail.value;
    if (this.allItems.length === 0) {
      this.loadData();
    }
    this.sortData();
  }

  handleChangeEmail(event) {
    let input = event.detail.value;
    if (this.isEmailValid(input)) {
      this.email = input;
    }
  }

  isEmailValid(emial) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(emial);
  }

  sortData() {
    this.columns.length = 0;
    this.allItems.forEach((element) => {
      if (element.Status__c === this.value || this.value === "All") {
        this.columns.push(element);
      }
    });
  }

  loadData() {
    this.allItems.length = 0;
    getLoans({ email: this.email, status: "All" })
      .then((result) => {
        let i = 0;
        result.forEach((element) => {
          let column = {
            key: i,
            itemId: element.Id,
            Item__c: element.Item__c,
            Status__c: element.Status__c,
            Borrower__c: element.Borrower__c,
            Penalty__c: element.Penalty__c,
            title: element.Item__r.Name,
            type: element.Item__r.Type__c,
            Rental_Date__c: element.Rental_Date__c,
            End_Of_Rental__c: element.End_Of_Rental__c
          };
          this.allItems.push(column);
          i = i + 1;
        });
        this.sortData();
      })
      .catch((error) => {
        console.error(error);
      });
  }

  footerButton() {
    let selectedLoans = [];

    this.selectedDivs.forEach((index) => {
      selectedLoans.push({
        Id: this.allItems[index].itemId,
        Item__c: this.allItems[index].Item__c,
        Borrower__c: this.allItems[index].Borrower__c,
        Rental_Date__c: this.allItems[index].Rental_Date__c,
        End_Of_Rental__c: this.allItems[index].End_Of_Rental__c,
        Status__c: this.allItems[index].Status__c
      });
    });

    updateLoans({ loans: selectedLoans });

    this.selectedDivs.length = 0;
    this.columns.length = 0;
    this.allItems.length = 0;

    // eslint-disable-next-line no-restricted-globals
    location.reload();
  }

  selectItem(event) {
    if (this.value === "Delay" || this.value === "Borrowed") {
      const przekazanaZmienna = event.target.dataset.id;
      const div = this.template.querySelector(
        `div[data-id="${przekazanaZmienna}"]`
      );
      const divID = div.id.split("-")[0];

      if (window.getComputedStyle(div).backgroundColor === this.unCheckedDiv) {
        div.style.backgroundColor = this.checkedDiv;
        this.selectedDivs.push(divID);
      } else {
        div.style.backgroundColor = this.unCheckedDiv;

        const indexToRemove = this.selectedDivs.indexOf(divID);
        if (indexToRemove !== -1) {
          this.selectedDivs.splice(indexToRemove, 1);
        }
      }
    }
  }
}
