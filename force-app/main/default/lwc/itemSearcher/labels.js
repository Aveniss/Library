import SelectTypeLabel from "@salesforce/label/c.SelectTypeLabel";
import DefaultRecordTypeId from "@salesforce/label/c.DefaultRecordTypeId";
import DataProcessingSucceededMessage from "@salesforce/label/c.DataProcessingSucceededMessage";

import SearchButtonLabel from "@salesforce/label/c.SearchButtonLabel";
import EnterIDLabel from "@salesforce/label/c.EnterIDLabel";
import EnterPINLabel from "@salesforce/label/c.EnterPINLabel";
import LoginDataPatternMessage from "@salesforce/label/c.LoginDataPatternMessage";
import RentButtonLabel from "@salesforce/label/c.RentButtonLabel";
import CancelButtonLabel from "@salesforce/label/c.CancelButtonLabel";
import SaveButtonLabel from "@salesforce/label/c.SaveButtonLabel";

import ITEM_FIELD_NAME from "@salesforce/schema/Item__c.Name";
import ITEM_FIELD_GENRE from "@salesforce/schema/Item__c.Genre__c";
import ITEM_FIELD_TYPE from "@salesforce/schema/Item__c.Type__c";
import ITEM_FIELD_PUBLISHING_HOUSE from "@salesforce/schema/Item__c.Publishing_House__c";
import ITEM_FIELD_LECTOR from "@salesforce/schema/Item__c.Lector__c";
import ITEM_FIELD_VERSION from "@salesforce/schema/Item__c.Version__c";

import ItemLabelName from "@salesforce/label/c.ItemLabelName";
import ItemLabelType from "@salesforce/label/c.ItemLabelType";
import ItemLabelGenre from "@salesforce/label/c.ItemLabelGenre";

import PaperBookItemType from "@salesforce/label/c.PaperBookItemType";
import MagazineItemType from "@salesforce/label/c.MagazineItemType";
import AudiobookItemType from "@salesforce/label/c.AudiobookItemType";

import ItemTypeErrorTitle from "@salesforce/label/c.ItemTypeErrorTitle";

import ItemLabelVersion from "@salesforce/label/c.ItemLabelVersion";
import ItemLabelLector from "@salesforce/label/c.ItemLabelLector";
import ItemLabelPublishingHouse from "@salesforce/label/c.ItemLabelPublishingHouse";

const labels = {
  SaveButtonLabel: SaveButtonLabel,
  CancelButtonLabel: CancelButtonLabel,
  RentButtonLabel: RentButtonLabel,
  LoginDataPatternMessage: LoginDataPatternMessage,
  EnterPINLabel: EnterPINLabel,
  EnterIDLabel: EnterIDLabel,
  DataProcessingSucceededMessage: DataProcessingSucceededMessage,
  PaperBookItemType: PaperBookItemType,
  MagazineItemType: MagazineItemType,
  AudiobookItemType: AudiobookItemType,
  ItemLabelVersion: ItemLabelVersion,
  ItemLabelPublishingHouse: ItemLabelPublishingHouse,
  ItemLabelLector: ItemLabelLector,
  ITEM_FIELD_PUBLISHING_HOUSE: ITEM_FIELD_PUBLISHING_HOUSE,
  ITEM_FIELD_LECTOR: ITEM_FIELD_LECTOR,
  ITEM_FIELD_VERSION: ITEM_FIELD_VERSION,
  SelectTypeLabel: SelectTypeLabel,
  ItemLabelName: ItemLabelName,
  DefaultRecordTypeId: DefaultRecordTypeId,
  SearchButtonLabel: SearchButtonLabel,
  ITEM_FIELD_NAME: ITEM_FIELD_NAME,
  ITEM_FIELD_GENRE: ITEM_FIELD_GENRE,
  ITEM_FIELD_TYPE: ITEM_FIELD_TYPE,
  ItemLabelType: ItemLabelType,
  ItemLabelGenre: ItemLabelGenre,
  ItemTypeErrorTitle: ItemTypeErrorTitle
};

export { labels };
