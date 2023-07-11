/**
 * Created by kamil on 10.07.2023.
 */

public with sharing class ItemConst {
    public static final ItemConst INSTANCE = new ItemConst();

    public final String API_NAME = Item__c.sObjectType.getDescribe().getName();

    public final Type TYPE = new Type();
    public final Genre GENRE = new Genre();

    public class Type {
        public final String PAPER_BOOK = 'Paper Book';
        public final String MAGAZINE = 'Magazine';
        public final String AUDIOBOOK = 'Audiobook';
    }

    public class Genre{
        public final String NOVEL = 'Novel';
        public final String SHORT_STORY = 'Short Story';
        public final String POETRY = 'Poetry';
        public final String TRAGEDY = 'Tragedy';
        public final String AUTOBIOGRAPHY = 'Autobiography';
        public final String SCIENCE_FICTIN = 'Science Fiction';
        public final String CRIME_FICTION = 'Crime Fiction';
        public final String ADVENTURE_NOVEL = 'Adventure Novel';
    }
}