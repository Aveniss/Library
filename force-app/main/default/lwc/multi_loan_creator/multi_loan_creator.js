/**
 * Created by kamil on 07.07.2023.
 */

import { LightningElement } from "lwc";
import getItems from "@salesforce/apex/MultiLoanCreatorController.getItems";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ShowTheLoan extends LightningElement {
  searchedItems = [];
  selectedItems = [];
  columns = [
    { label: "Name", fieldName: "Name", type: "text" },
    { label: "Type", fieldName: "Type__c", type: "text" },
    { label: "Genre", fieldName: "Genre__c", type: "text" }
  ];
  get options() {
    return [
      { label: "Paper Book", value: "Paper Book" },
      { label: "Magazine", value: "Magazine" },
      {
        label: "Audiobook",
        value: "Audiobook"
      }
    ];
  }

  itemName = "";
  itemType = "";

  handleChangeType(event) {
    this.itemType = event.detail.value;
  }
  handleChangeName(event) {
    this.itemName = event.detail.value;
  }

  get getSearchedItems() {
    return this.searchedItems;
  }
  get getSelectedItems() {
    return this.selectedItems;
  }
  changeOnSelect(event) {
    const selectedRows = event.detail.selectedRows;
    if (selectedRows.length) {
      this.searchedItems = this.searchedItems.map((element) => {
        console.log(element.Id + " " + selectedRows[0].Id);

        let found = selectedRows.some((item) => item.Id === element.Id);
        console.log("wynik metody: " + found);
        return found ? { ...element, selected: true } : element;
      });

      console.log("cos poszlo " + selectedRows[0].selected);
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

  searchNewItems() {
    getItems({
      name: this.itemName,
      type: this.itemType,
      genre: "",
      additionalFiler: ""
    })
      .then((result) => {
        this.searchedItems = result.map((element) => ({
          ...element,
          selected: false
        }));
        console.log("result: " + this.searchedItems);
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

  createNewLoans() {
    console.log(
      "Itemy: " +
        this.searchedItems[0].selected +
        " " +
        this.searchedItems[0].Name +
        " " +
        this.searchedItems[0].Type__c +
        " " +
        this.searchedItems[0].Genre__c +
        " "
    );
  }
}
