package com.finegamedesign.spellstone
{
    public class Model
    {
        internal static const EMPTY:String = " ";
        internal static const LETTER_MAX:int = 8;
        internal static const LETTER_MIN:int = 3;
        internal static var levels:Array = [
            {columnCount: 5, rowCount: 1, diagram: "START"},
            {columnCount: 3, rowCount: 2},
            {columnCount: 3, rowCount: 3},
            {columnCount: 4, rowCount: 3},
            {columnCount: 5, rowCount: 3},
            {columnCount: 6, rowCount: 3},
            {columnCount: 6, rowCount: 4}
        ];

        internal var diagram:String;
        internal var kill:int;
        internal var maxKill:int;
        internal var cellCount:int;
        internal var columnCount:int;
        internal var onContagion:Function;
        internal var onDeselect:Function;
        internal var onDie:Function;
        internal var rowCount:int;
        internal var selected:Array;
        internal var table:Array;
        internal var highScore:int;
        internal var score:int;
        internal var restartScore:int;

        public function Model()
        {
            score = 0;
            highScore = 0;
            restartScore = 0;
        }

        internal function populate(levelParams:Object):void
        {
            for (var param:String in levelParams) {
                this[param] = levelParams[param];
            }
            if ("diagram" in levelParams) {
                table = levelParams.diagram.split("");
            }
            else {
                table = [];
                cellCount = rowCount * columnCount;
                var letters:Array = shuffleLetters(Words.lists[0],
                    cellCount, LETTER_MIN);
                for (var c:int = 0; c < cellCount; c++) {
                    table.push(letters[c]);
                }
                shuffle(table);
            }
            selected = [];
            kill = 0;
            restartScore = score;
            maxKill = columnCount * rowCount;
        }

        private static function randomLetter():String
        {
            var ALPHABET:Array = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");
            var i:int = Math.random() * ALPHABET.length;
            var letter:String = ALPHABET[i];
            return letter;
        }

        private function shuffleLetters(list:Array,
                cellCount:int, wordLength:int):Array
        {
            var letters:Array = [];
            shuffle(list);
            while (letters.length < cellCount) {
                for (var s:int = 0; letters.length < cellCount 
                                    && s < list.length; s++) {
                    var word:String = list[s];
                    if (word.length == wordLength) {
                        trace("Model.shuffleLetters: " + word);
                        letters = letters.concat(word.split(""));
                    }
                }
            }
            if (cellCount < letters.length) {
                throw new Error("Expected exactly one letter for each cell.  Got " + letters.length + " letters for " + cellCount + " cells.");
            }
            shuffle(letters);
            return letters;
        }

        private function shuffle(array:Array):void
        {
            for (var i:int = array.length - 1; 1 <= i; i--) {
                var j:int = (i + 1) * Math.random();
                var tmp:* = array[i];
                array[i] = array[j];
                array[j] = tmp;
            }
        }

        internal function indexAt(column:int, row:int):int
        {
            return row * columnCount + column;
        }

        /**
         * Just mouse down.  Select or deselect.
         */
        internal function select(i:int):Boolean
        {
            var push:Boolean;
            var index:int = selected.indexOf(i);
            if (index <= -1) {
                selected.push(i);
                if (null != onContagion) {
                    onContagion();
                }
                push = true;
            }
            else {
                selected.splice(index, 999);
                push = false;
                if (null != onDeselect) {
                    onDeselect();
                }
            }
            return push;
        }

        private function spell(selected:Array, letters:Array):String
        {
            var word:String = "";
            for (var s:int = 0; s < selected.length; s++) {
                word += letters[selected[s]];
            }
            return word;
        }

        /**
         * Removed addresses if 3 or more.
         * Set index to EMPTY and cell to null, in case view still refers to cell.
         */
        internal function judge():Array
        {
            var removed:Array = [];
            if (LETTER_MIN <= selected.length) {
                var word:String = spell(selected, table);
                trace("Model.judge: word <" + word + ">");
                if (Words.has(word)) {
                    removed = selected.slice();
                    trace("Model.judge: removed " + removed);
                    for each(var address:int in removed) {
                        table[address] = EMPTY;
                    }
                    scoreUp(removed.length);
                    if (null != onDie) {
                        onDie();
                    }
                }
            }
            selected = [];
            return removed;
        }
   
        /**
         * 0, 0, 10, 20, 40,  80, 160, 320, 640, 1280, 2560, 5120, ...
         */
        private function scoreUp(length:int):void
        {
            kill += length;
            var points:int = Math.pow(2, length - 2);
            points *= 10;
            score += points;
            if (highScore < score) {
                highScore = score;
            }
        }

        /**
         * Remove all cells.
         * Rollback score.
         */
        internal function clear():void
        {
            for (var i:int = 0; i < table.length; i++) {
                if (null != table[i]) {
                    table[i] = EMPTY;
                }
            }
            score = restartScore;
        }

        internal function update():int
        {
            return win();
        }

        /**
         * TODO: Lose if no moves remaining.
         * @return  0 continue, 1: win, -1: lose.
         */
        private function win():int
        {
            var winning:int = 0;
            if (maxKill <= kill) {
                winning = 1;
            }
            else if (false) {
                winning = -1;
            }
            return winning;
        }
    }
}
