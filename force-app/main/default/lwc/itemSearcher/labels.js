import ItemNameLabel from "@salesforce/label/c.ItemNameLabel";
import SelectTypeLabel from "@salesforce/label/c.SelectTypeLabel";
import DefaultRecordTypeId from "@salesforce/label/c.DefaultRecordTypeId";

import SearchButtonLabel from "@salesforce/label/c.SearchButtonLabel";

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
  ItemNameLabel: ItemNameLabel,
  DefaultRecordTypeId: DefaultRecordTypeId,
  SearchButtonLabel: SearchButtonLabel,
  ITEM_FIELD_NAME: ITEM_FIELD_NAME,
  ITEM_FIELD_GENRE: ITEM_FIELD_GENRE,
  ITEM_FIELD_TYPE: ITEM_FIELD_TYPE,
  ItemLabelName: ItemLabelName,
  ItemLabelType: ItemLabelType,
  ItemLabelGenre: ItemLabelGenre,
  ItemTypeErrorTitle: ItemTypeErrorTitle
};

export { labels };
