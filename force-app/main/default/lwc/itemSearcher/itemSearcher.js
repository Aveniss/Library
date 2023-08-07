/**
 * Created by kamil on 06.08.2023.
 */

import { LightningElement, track, wire } from "lwc";
import { labels } from "./labels.js";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchItems from "@salesforce/apex/ItemSearcherController.searchItems";

export default class HelloComponentForVFLWC extends LightningElement {
  myLabel = labels;
  @track items = [];
  @track itemTypes = [];
  @track itemGenres = [];

  @track isBook = false;
  @track isMagazine = false;
  @track isAudiobook = false;

  itemName = "";
  selectedType = "";
  selectedGenre = "";
  selectedVersion = 0;
  selectedLector = "";
  selectedPublishingHouse = "";

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

  handleChangeType(event) {
    this.isBook = false;
    this.isMagazine = false;
    this.isAudiobook = false;
    this.selectedType = "";
    this.selectedGenre = "";
    this.selectedVersion = 0;
    this.selectedLector = "";
    this.selectedPublishingHouse = "";

    this.selectedType = event.target.value;

    if (this.selectedType === "Paper Book") {
      this.isBook = true;
    } else if (this.selectedType === "Magazine") {
      this.isMagazine = true;
    } else {
      this.isAudiobook = true;
    }
  }

  handleChangeName(event) {
    this.itemName = event.target.value;
  }

  handleChangeGenre(event) {
    this.selectedGenre = event.target.value;
  }

  handleChangeLector(event) {
    this.selectedLector = event.target.value;
  }

  handleChangeVersion(event) {
    this.selectedVersion = event.target.value;
  }

  handleChangePublishingHouse(event) {
    this.selectedPublishingHouse = event.target.value;
  }

  loadData() {
    searchItems({
      name: this.itemName,
      type: this.selectedType,
      genre: this.selectedGenre,
      version: this.selectedVersion,
      publishingHouse: this.selectedPublishingHouse,
      lector: this.selectedLector
    })
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
