/**
 * Created by kamil on 06.08.2023.
 */

import { LightningElement, track, wire } from "lwc";
import { labels } from "./labels.js";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchItems from "@salesforce/apex/ItemSearcherController.searchItems";

export default class itemSearcher extends LightningElement {
  myLabel = labels;
  @track items = [];
  @track itemTypes = [];
  @track itemGenres = [];
  searchProperties = {};

  get getBookStatus() {
    return (
      this.searchProperties[labels.ITEM_FIELD_TYPE.fieldApiName] ===
      "Paper Book"
    );
  }

  get getMagazineStatus() {
    return (
      this.searchProperties[labels.ITEM_FIELD_TYPE.fieldApiName] === "Magazine"
    );
  }

  get getAudiobookStatus() {
    return (
      this.searchProperties[labels.ITEM_FIELD_TYPE.fieldApiName] === "Audiobook"
    );
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

  handleFieldChange(event) {
    if (event.target.name === labels.ITEM_FIELD_TYPE.fieldApiName) {
      let itemName = this.searchProperties[labels.ITEM_FIELD_NAME.fieldApiName];

      if (itemName) {
        this.searchProperties = {
          [labels.ITEM_FIELD_NAME.fieldApiName]: itemName
        };
      } else {
        this.searchProperties = {};
      }
    }
    this.searchProperties = {
      ...this.searchProperties,
      [event.target.name]: event.target.value
    };
  }

  loadData() {
    searchItems({ searchProperties: this.searchProperties })
      .then((result) => {
        this.items = result;
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
}
