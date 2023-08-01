/**
 * Created by kamil on 07.07.2023.
 */

import {api, LightningElement} from "lwc";
import getItems from "@salesforce/apex/MultiLoanCreatorController.getItems";
import createLoans from "@salesforce/apex/MultiLoanCreatorController.createLoans";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

import SearchedDatatableLabel from "@salesforce/label/c.SearchedDatatableLabel";
import SelectedDatatable from "@salesforce/label/c.SelectedDatatable";
import SelectStatusLabel from "@salesforce/label/c.SelectStatusLabel";
import DateFieldLabel from "@salesforce/label/c.DateFieldLabel";
import ItemNameLabel from "@salesforce/label/c.ItemNameLabel";
import SelectTypeLabel from "@salesforce/label/c.SelectTypeLabel";

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
    itemName = "";
    itemType = "";
    loanStatus = "";
    endOfLoan = "";

    searchedItems = [];
    selectedItems = [];
    columns = [
        {label: "Name", fieldName: "Name", type: "text"},
        {
            label: "Type",
            fieldName: "Type__c",
            type: "text"
        },
        {label: "Genre", fieldName: "Genre__c", type: "text"}
    ];

    get itemTypes() {
        return [
            {label: "Paper Book", value: "Paper Book"},
            {label: "Magazine", value: "Magazine"},
            {
                label: "Audiobook",
                value: "Audiobook"
            }
        ];
    }

    handleDateChange(event) {
        const selectedDate = new Date(event.target.value);
        const today = new Date();

        if (selectedDate <= today) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Invalid Date",
                    message: "The date cannot be earlier than tomorrow",
                    variant: "error"
                })
            );
            event.target.value = "";
        } else {
            this.endOfLoan = selectedDate;
        }
    }

    get checkButtonStatus() {
        return !(
            this.selectedItems.length !== 0 &&
            this.endOfLoan !== "" &&
            this.loanStatus !== ""
        );
    }

    handleLoanStatusChange(event) {
        this.loanStatus = event.target.value;
    }

    get newStatusOptions() {
        return [
            {label: "Reservation", value: "Reservation"},
            {label: "Borrowed", value: "Borrowed"}
        ];
    }

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
                return selectedRows.some((item) => item.Id === element.Id)
                    ? {...element, selected: true}
                    : element;
            });
        }
    }

    changeOnUnselect(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length) {
            this.selectedItems = this.selectedItems.map((element) => {
                return selectedRows.some((item) => item.Id === element.Id)
                    ? {...element, selected: false}
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
                        title: "Data Download Failed",
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
            .catch((insertError) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Data Insert Failed",
                        message: insertError.message,
                        variant: "error"
                    })
                );
            })
            .then(() => {
                // eslint-disable-next-line no-restricted-globals
                location.reload();
            });
    }
}
