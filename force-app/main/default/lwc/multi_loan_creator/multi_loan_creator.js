/**
 * Created by kamil on 07.07.2023.
 */

import { api, LightningElement, track, wire } from "lwc";
import getItems from "@salesforce/apex/MultiLoanCreatorController.getItems";
import createLoans from "@salesforce/apex/MultiLoanCreatorController.createLoans";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from "lightning/refresh";
import { getPicklistValues } from "lightning/uiObjectInfoApi";

import SearchedDatatableLabel from "@salesforce/label/c.SearchedDatatableLabel";
import SelectedDatatable from "@salesforce/label/c.SelectedDatatable";
import SelectStatusLabel from "@salesforce/label/c.SelectStatusLabel";
import DateFieldLabel from "@salesforce/label/c.DateFieldLabel";
import ItemNameLabel from "@salesforce/label/c.ItemNameLabel";
import SelectTypeLabel from "@salesforce/label/c.SelectTypeLabel";
import DefaultRecordTypeId from "@salesforce/label/c.DefaultRecordTypeId";

import ITEM_FIELD_NAME from "@salesforce/schema/Item__c.Name";
import ITEM_FIELD_GENRE from "@salesforce/schema/Item__c.Genre__c";
import ITEM_FIELD_TYPE from "@salesforce/schema/Item__c.Type__c";

import TYPE_FIELD from "@salesforce/schema/Item__c.Type__c";
import STATUS_FIELD from "@salesforce/schema/Loan__c.Status__c";

import ItemLabelName from "@salesforce/label/c.ItemLabelName";
import ItemLabelType from "@salesforce/label/c.ItemLabelType";
import ItemLabelGenre from "@salesforce/label/c.ItemLabelGenre";

import DataInsertFailedTitle from "@salesforce/label/c.DataInsertFailedTitle";
import DataDownloadFailedTitle from "@salesforce/label/c.DataDownloadFailedTitle";
import DataProcessingSucceeded from "@salesforce/label/c.DataProcessingSucceeded";
import DataProcessingSucceededMessage from "@salesforce/label/c.DataProcessingSucceededMessage";
import ItemTypeErrorTitle from "@salesforce/label/c.ItemTypeErrorTitle";
import LoanStatusErrorTitle from "@salesforce/label/c.LoanStatusErrorTitle";

export default class ShowTheLoan extends LightningElement {
  label = {
    SelectTypeLabel,
    SearchedDatatableLabel,
    SelectedDatatable,
    SelectStatusLabel,
    DateFieldLabel,
    ItemNameLabel
  };

  @api recordId;
  itemName = '';
  itemType = '';
  loanStatus = '';
  endOfLoan = '';

  @track searchedItems = [];
  @track selectedItems = [];
  @track itemTypes = [];
  @track newStatusOptions = [];

  columns = [
    { label: ItemLabelName, fieldName: ITEM_FIELD_NAME.fieldApiName },
    {
      label: ItemLabelType,
      fieldName: ITEM_FIELD_TYPE.fieldApiName
    },
    { label: ItemLabelGenre, fieldName: ITEM_FIELD_GENRE.fieldApiName }
  ];

  @wire(getPicklistValues, {
    recordTypeId: DefaultRecordTypeId,
    fieldApiName: TYPE_FIELD
  })
  getTypePicklistValues({ error, data }) {
    if (data) {
      this.itemTypes = data.values;
    } else if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: ItemTypeErrorTitle,
          message: error.message,
          variant: "error"
        })
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: DefaultRecordTypeId,
    fieldApiName: STATUS_FIELD
  })
  getStatusPicklistValues({ error, data }) {
    if (data) {
      this.newStatusOptions = data.values;
    } else if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: LoanStatusErrorTitle,
          message: error.message,
          variant: "error"
        })
      );
    }
  }

  handleDateChange(event) {
    this.endOfLoan = event.target.value;
  }

  get getMinimumDate() {
    let currentDate = new Date();
    currentDate.setDate(currentDate.getDate() + 1);
    return currentDate.toISOString().slice(0, 10);
  }

  get checkButtonStatus() {
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
            title: DataDownloadFailedTitle,
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
        this.selectedItems.length = 0;
        this.dispatchEvent(new RefreshEvent());
        this.dispatchEvent(
          new ShowToastEvent({
            title: DataProcessingSucceeded,
            message: DataProcessingSucceededMessage,
            variant: "success"
          })
        );
      })
      .catch((insertError) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: DataInsertFailedTitle,
            message: insertError.message,
            variant: "error"
          })
        );
      });
  }
}
