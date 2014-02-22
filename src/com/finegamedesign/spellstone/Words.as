package com.finegamedesign.spellstone
{
    public class Words
    {
        private static var hash:Object;
        [Embed(source="../../../../txt/word_list_moby_crossword.flat.txt", mimeType="application/octet-stream")]
        private static const WordList:Class;

        internal static function init():void
        {
            if (null == hash) {
                hash = parse(String(new WordList()));
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

        private static function parse(wordList:String):Object
        {
            var hash:Object = {};
            var list:Array = wordList.replace(/\r\n/g, "\n").split("\n");
            for (var w:int = 0; w < list.length; w++) {
                hash[list[w]] = true;
            }
            trace("Words.parse: " + list.length + " words");
            return hash;
        }
    }
}
