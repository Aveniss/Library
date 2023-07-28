/**
 * Created by kamil on 07.07.2023.
 */

import { LightningElement, track } from "lwc";
import getItems from "@salesforce/apex/MultiLoanCreatorController.getItems";

export default class ShowTheLoan extends LightningElement {
  itemType = "";
  itemName = "";

  _selected = [];

  @track rightItems = [
    { label: "Option 1", value: "option1" },
    { label: "Option 2", value: "option2" },
    { label: "Option 3", value: "option3" }
    // Dodaj inne elementy jako potrzebne
  ];

  @track selectedItems = ["option2"];

  random = [];

  get itemTypes() {
    return [
      { label: "PAPER BOOK", value: "Paper Book" },
      { label: "MAGAZINE", value: "Magazine" },
      { label: "AUDIOBOOK", value: "Audiobook" }
    ];
  }

  // do zamiany z datatable

  get options() {
    // return getItems({name: this.itemName,type:this.itemType,genre:'',additionalFiler:''});
    return this.random;
  }

  get selected() {
    return this._selected.length ? this._selected : "none";
  }

  handleChange(e) {
    this._selected.push(...e.detail.value);
  }

  handleChangeName(e) {
    this.itemName = e.detail.value;
  }

  showQueryItems() {
    console.log("Poszlo");
    getItems({
      name: this.itemName,
      type: this.itemType,
      genre: "",
      additionalFiler: ""
    }).then((result) => {
      this.random = result.map((item) => ({
        label: item.Name,
        value: item.Id
      }));
    });
    console.log(this.random);
  }

  handleChangeType(e) {
    this.itemType = e.detail.value;
  }
}
