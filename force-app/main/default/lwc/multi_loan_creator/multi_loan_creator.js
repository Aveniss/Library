/**
 * Created by kamil on 07.07.2023.
 */

import { LightningElement, track } from "lwc";
import getItems from "@salesforce/apex/MultiLoanCreator.getItems";

export default class ShowTheLoan extends LightningElement {
  // eslint-disable-next-line @lwc/lwc/no-document-query
  @track columns = [];
  @track selectedItems = [];

  checkedDiv = "rgb(40, 128, 247)";
  unCheckedDiv = "rgb(244, 246, 249)";

  itemType = "";
  itemName = "";
  additionalFilter = "";

  isBook = false;
  isAudiobook = false;
  isMagazine = false;

  get options() {
    return [
      { label: "Book", value: "Paper Book" },
      { label: "Audiobook", value: "Audiobook" },
      { label: "Magazine", value: "Magazine" }
    ];
  }

  get getAddtionalOptions() {
    return [
      { label: "Adventure Novel", value: "Adventure Novel" },
      { label: "Adventure Novel", value: "Adventure Novel" },
      { label: "Crime Fiction", value: "Crime Fiction" },
      { label: "Novel", value: "Novel" },
      { label: "Poetry", value: "Poetry" },
      { label: "Science Fiction", value: "Science Fiction" },
      { label: "Short Story", value: "Short Story" },
      { label: "Tragedy", value: "Tragedy" }
    ];
  }

  selectAdditionalFilter(event) {
    this.additionalFilter = event.detail.value;
  }
  selectItemName(event) {
    this.itemName = event.detail.value;
  }

  handleChange(event) {
    this.isBook = false;
    this.isAudiobook = false;
    this.isMagazine = false;

    this.itemType = event.detail.value;

    if (this.itemType === "Paper Book") {
      this.isBook = true;
    } else if (this.itemType === "Audiobook") {
      this.isAudiobook = true;
    } else {
      this.isMagazine = true;
    }
  }

  loadData() {
    this.columns.length = 0;
    let filters = {};
    if (this.isBook) {
      filters = {
        name: this.itemName,
        type: this.itemType,
        genre: this.additionalFilter,
        additionalFiler: ""
      };
    } else if (this.isMagazine || this.isAudiobook) {
      filters = {
        name: this.itemName,
        type: this.itemType,
        genre: "",
        additionalFiler: this.additionalFilter
      };
    } else {
      filters = {
        name: this.itemName,
        type: "",
        genre: "",
        additionalFiler: ""
      };
    }
    getItems(filters)
      .then((result) => {
        let i = 0;
        result.forEach((element) => {
          let column = {
            key: i,
            itemId: element.Id,
            Name: element.Name,
            Type__c: element.Type__c
          };
          this.columns.push(column);
          i = i + 1;
        });
      })
      .catch((error) => {
        console.error(error);
      });
  }

  selectItem(event) {
    const przekazanaZmienna = event.target.dataset.id;
    const div = this.template.querySelector(
      `div[data-id="${przekazanaZmienna}"]`
    );
    const divID = div.id.split("-")[0];

    if (window.getComputedStyle(div).backgroundColor === this.unCheckedDiv) {
      div.style.backgroundColor = this.checkedDiv;
      this.selectedItems.push(this.columns[divID].itemId);
    } else {
      div.style.backgroundColor = this.unCheckedDiv;

      const indexToRemove = this.selectedItems.indexOf(
        this.columns[divID].itemId
      );
      if (indexToRemove !== -1) {
        this.selectedItems.splice(indexToRemove, 1);
      }
    }
    console.log(this.selectedItems[0]);
  }
}
