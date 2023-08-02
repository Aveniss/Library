import SearchedDatatableLabel from "@salesforce/label/c.SearchedDatatableLabel";
import SelectedDatatable from "@salesforce/label/c.SelectedDatatable";
import SelectStatusLabel from "@salesforce/label/c.SelectStatusLabel";
import DateFieldLabel from "@salesforce/label/c.DateFieldLabel";
import ItemNameLabel from "@salesforce/label/c.ItemNameLabel";
import SelectTypeLabel from "@salesforce/label/c.SelectTypeLabel";
import DefaultRecordTypeId from "@salesforce/label/c.DefaultRecordTypeId";

import CreateButtonLabel from "@salesforce/label/c.CreateButtonLabel";
import SearchButtonLabel from "@salesforce/label/c.SearchButtonLabel";

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

const labels = {
  SelectTypeLabel: SelectTypeLabel,
  SearchedDatatableLabel: SearchedDatatableLabel,
  SelectedDatatable: SelectedDatatable,
  SelectStatusLabel: SelectStatusLabel,
  DateFieldLabel: DateFieldLabel,
  ItemNameLabel: ItemNameLabel,
  DefaultRecordTypeId: DefaultRecordTypeId,
  CreateButtonLabel: CreateButtonLabel,
  SearchButtonLabel: SearchButtonLabel,
  ITEM_FIELD_NAME: ITEM_FIELD_NAME,
  ITEM_FIELD_GENRE: ITEM_FIELD_GENRE,
  ITEM_FIELD_TYPE: ITEM_FIELD_TYPE,
  TYPE_FIELD: TYPE_FIELD,
  STATUS_FIELD: STATUS_FIELD,
  ItemLabelName: ItemLabelName,
  ItemLabelType: ItemLabelType,
  ItemLabelGenre: ItemLabelGenre,
  DataInsertFailedTitle: DataInsertFailedTitle,
  DataDownloadFailedTitle: DataDownloadFailedTitle,
  DataProcessingSucceeded: DataProcessingSucceeded,
  DataProcessingSucceededMessage: DataProcessingSucceededMessage,
  ItemTypeErrorTitle: ItemTypeErrorTitle,
  LoanStatusErrorTitle: LoanStatusErrorTitle
};

export { labels };
