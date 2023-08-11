/**
 * Created by kamil on 06.08.2023.
 */

import { LightningElement, track, wire } from "lwc";
import { labels } from "./labels.js";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchItems from "@salesforce/apex/ItemSearcherController.searchItems";
import createNewLoans from "@salesforce/apex/ItemSearcherController.createNewLoans";

const SELECTED_DIV_STYLE =
  "selectedDiv custom-box slds-box slds-p-around_medium slds-text-align_center";
const UNSELECTED_DIV_STYLE =
  "unselectedDiv custom-box slds-box slds-p-around_medium slds-text-align_center";

export default class itemSearcher extends LightningElement {
  myLabel = labels;
  items = [];
  @track itemTypes = [];
  @track itemGenres = [];
  searchProperties = {};
  openModal = false;
  selectedType = "";
  userID;
  userPIN;
  columns = [
    {
      label: labels.ItemLabelName,
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

  get isBook() {
    return (
      this.searchProperties[labels.ITEM_FIELD_TYPE.fieldApiName] ===
      labels.PaperBookItemType
    );
  }

  get isMagazine() {
    return (
      this.searchProperties[labels.ITEM_FIELD_TYPE.fieldApiName] ===
      labels.MagazineItemType
    );
  }

  get isAudiobook() {
    return (
      this.searchProperties[labels.ITEM_FIELD_TYPE.fieldApiName] ===
      labels.AudiobookItemType
    );
  }

  get newRentAvailability() {
    return this.items.filter((element) => element.Selected).length === 0;
  }

  get dialogClass() {
    const open = this.openModal ? "slds-fade-in-open" : "";
    return `slds-modal slds-modal_medium ${open}`;
  }

  get getItems() {
    return this.items
      .filter(
        (element) => !this.selectedType || element.Type__c === this.selectedType
      )
      .map((element) => ({
        ...element,
        Style: element.Selected ? SELECTED_DIV_STYLE : UNSELECTED_DIV_STYLE
      }));
  }

  get backdropClass() {
    return this.openModal
      ? "slds-backdrop_open slds-backdrop blurry-background"
      : "";
  }

  @wire(getPicklistValues, {
    recordTypeId: labels.DefaultRecordTypeId,
    fieldApiName: labels.ITEM_FIELD_TYPE
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
    fieldApiName: labels.ITEM_FIELD_GENRE
  })
  getGenrePicklistValues({ error, data }) {
    if (data) {
      this.itemGenres = data.values;
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

  enterUserID(event) {
    this.userID = event.target.value;
  }

  enterUserPIN(event) {
    this.userPIN = event.target.value;
  }

  handleFieldChange(event) {
    if (event.target.name === labels.ITEM_FIELD_TYPE.fieldApiName) {
      let itemName = this.searchProperties[labels.ITEM_FIELD_NAME.fieldApiName];
      this.selectedType = event.target.value;
      this.searchProperties = itemName
        ? { [labels.ITEM_FIELD_NAME.fieldApiName]: itemName }
        : {};
    }
    this.searchProperties = {
      ...this.searchProperties,
      [event.target.name]: event.target.value
    };
  }

  changeModalStatus() {
    this.openModal = !this.openModal;
  }

  loadData() {
    let selectedItems = this.items.filter((element) => element.Selected);
    searchItems({ searchProperties: this.searchProperties })
      .then((result) => {
        this.items = selectedItems.concat(
          result.filter(
            (element1) =>
              !selectedItems.some((element2) => element1.Id === element2.Id)
          )
        );
      })
      .catch((downloadError) => {
        const event = new CustomEvent("myEvent", {
          detail: downloadError.message
        });
        this.dispatchEvent(event);
      });
  }

  filteredItems() {
    return this.items.filter((element) => element.Selected);
  }
  createLoans() {
    this.changeModalStatus();
    createNewLoans({
      items: this.filteredItems(),
      userPIN: this.userPIN,
      userID: this.userID
    })
      .then(() => {
        this.items = [];
        const event = new CustomEvent("myEvent", {
          detail: labels.DataProcessingSucceededMessage
        });
        this.dispatchEvent(event);
      })
      .catch((error) => {
        const event = new CustomEvent("myEvent", {
          detail: error.body.pageErrors[0].message
        });
        this.dispatchEvent(event);
      });
  }

  selectItem(event) {
    const itemID = event.target.dataset.id;
    let item = this.items.find((element) => element.Id === itemID);
    item.Selected = !item.Selected;
    this.items = this.items.map((element) => ({ ...element }));
  }
}
