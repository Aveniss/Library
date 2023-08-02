/**
 * Created by kamil on 07.07.2023.
 */

import { api, LightningElement, track, wire } from "lwc";
import getItems from "@salesforce/apex/MultiLoanCreatorController.getItems";
import createLoans from "@salesforce/apex/MultiLoanCreatorController.createLoans";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { labels } from "./labels.js";

export default class ShowTheLoan extends LightningElement {
  @api recordId;
  itemName = "";
  itemType = "";
  loanStatus = "";
  endOfLoan = "";
  myLabel = labels;
  minimumDate = "";

  @track searchedItems = [];
  @track selectedItems = [];
  @track itemTypes = [];
  @track newStatusOptions = [];

  columns = [
    {
      label: labels.ItemNameLabel,
      fieldName: labels.ITEM_FIELD_NAME.fieldApiName
    },
    {
      label: labels.ItemLabelType,
      fieldName: labels.ITEM_FIELD_TYPE.fieldApiName
    },
    {
      label: labels.ItemLabelGenre,
      fieldName: labels.ITEM_FIELD_GENRE.fieldApiName
    }
  ];

  connectedCallback() {
    let currentDate = new Date();
    currentDate.setDate(currentDate.getDate() + 1);
    this.minimumDate = currentDate.toISOString().slice(0, 10);
  }

  @wire(getPicklistValues, {
    recordTypeId: labels.DefaultRecordTypeId,
    fieldApiName: labels.TYPE_FIELD
  })
  getTypePicklistValues({ error, data }) {
    if (data) {
      this.itemTypes = data.values;
    } else if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: labels.ItemTypeErrorTitle,
          message: error.message,
          variant: "error"
        })
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: labels.DefaultRecordTypeId,
    fieldApiName: labels.STATUS_FIELD
  })
  getStatusPicklistValues({ error, data }) {
    if (data) {
      this.newStatusOptions = data.values;
    } else if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: labels.LoanStatusErrorTitle,
          message: error.message,
          variant: "error"
        })
      );
    }
  }

  handleDateChange(event) {
    this.endOfLoan = event.target.value;
  }
  get checkRequiredFields() {
    return !(this.selectedItems.length && this.endOfLoan && this.loanStatus);
  }

  handleLoanStatusChange(event) {
    this.loanStatus = event.target.value;
  }

  handleChangeType(event) {
    this.itemType = event.detail.value;
  }

  handleChangeName(event) {
    this.itemName = event.detail.value;
  }

  changeOnSelect(event) {
    const selectedRows = event.detail.selectedRows;
    if (selectedRows.length) {
      this.searchedItems = this.searchedItems.map((element) => {
        return selectedRows.some((item) => item.Id === element.Id)
          ? { ...element, selected: true }
          : element;
      });
    }
  }

  changeOnUnselect(event) {
    const selectedRows = event.detail.selectedRows;
    if (selectedRows.length) {
      this.selectedItems = this.selectedItems.map((element) => {
        return selectedRows.some((item) => item.Id === element.Id)
          ? { ...element, selected: false }
          : element;
      });
    }
  }

  moveSelectedItems() {
    this.selectedItems = [
      ...this.selectedItems,
      ...this.searchedItems.filter((element) => element.selected)
    ];
    this.searchedItems = this.searchedItems.filter(
      (element) => !element.selected
    );
  }

  moveUnselectedItems() {
    this.searchedItems = [
      ...this.searchedItems,
      ...this.selectedItems.filter((element) => !element.selected)
    ];
    this.selectedItems = this.selectedItems.filter(
      (element) => element.selected
    );
  }

  searchNewItems() {
    let allIDs = this.selectedItems.map((item) => item.Id);
    getItems({
      name: this.itemName,
      type: this.itemType,
      existingIDs: allIDs
    })
      .then((result) => {
        this.searchedItems = result.map((element) => ({
          ...element,
          selected: false
        }));
      })
      .catch((downloadError) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: labels.DataDownloadFailedTitle,
            message: downloadError.message,
            variant: "error"
          })
        );
      });
  }
  createNewLoans() {
    createLoans({
      borrowerId: this.recordId,
      items: this.selectedItems,
      endOfRental: this.endOfLoan,
      status: this.loanStatus
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: labels.DataProcessingSucceeded,
            message: labels.DataProcessingSucceededMessage,
            variant: "success"
          })
        );
        this.selectedItems = [];
      })
      .catch((insertError) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: labels.DataInsertFailedTitle,
            message: insertError.message,
            variant: "error"
          })
        );
      });
  }
}
