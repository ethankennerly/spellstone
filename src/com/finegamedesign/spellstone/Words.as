package com.finegamedesign.spellstone
{
    public class Words
    {
        internal static var lists:Array;

        private static var hash:Object;
        [Embed(source="../../../../txt/word_list_moby_crossword.flat.txt", mimeType="application/octet-stream")]
        private static const AllWordList:Class;
        [Embed(source="../../../../txt/bigiqkids.com_wordlist_spelling_grade_1.txt", mimeType="application/octet-stream")]
        private static const Grade1List:Class;

        internal static function init():void
        {
            if (null == hash) {
                hash = constructHash(String(new AllWordList()));
            }
            if (null == lists) {
                lists = [];
                lists.push(array(String(new Grade1List())));
            }
        }

        internal static function has(word:String):Boolean
        {
            if (word in hash) {
                return true;
            }
            else {
                return false;
            }
        }

        private static function constructHash(wordList:String):Object
        {
            var hash:Object = {};
            var list:Array = array(wordList);
            for (var w:int = 0; w < list.length; w++) {
                hash[list[w]] = true;
            }
            trace("Words.parse: " + list.length + " words");
            return hash;
        }

        private static function array(wordList:String):Array
        {
            return wordList.replace(/\r\n/g, "\n").split("\n");
        }
    }
}
