package com.finegamedesign.spellstone
{
    public class Model
    {
        internal static const EMPTY:String = " ";
        internal static const LETTER_MAX:int = 8;
        internal static const LETTER_MIN:int = 3;
        internal static var levels:Array = [
            {columnCount: 4, rowCount: 1, diagram: "PLAY"},
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
        internal var round:int;
        internal var roundMax:int = levels.length;  
                                    // 1;  // debug
        internal var words:Array;

        public function Model()
        {
            highScore = 0;
            restart();
        }

        internal function restart():void
        {
            round = 1;
            score = 0;
            restartScore = 0;
        }

        internal function populate(levelParams:Object):void
        {
            for (var param:String in levelParams) {
                this[param] = levelParams[param];
            }
            if ("diagram" in levelParams) {
                table = levelParams.diagram.split("");
                words = [levelParams.diagram];
            }
            else {
                cellCount = rowCount * columnCount;
                words = shuffleWords(Words.lists[0],
                    cellCount, LETTER_MIN, LETTER_MAX);
                table = fillTable(words, columnCount, rowCount);
                round++;
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

        /**
         * 
         */
        private function shuffleWords(list:Array,
                cellCount:int, minLength:int, maxLength:int):Array
        {
            var words:Array = [];
            shuffle(list);
            var letterCount:int = 0;
            while (letterCount < cellCount) {
                for (var s:int = 0; letterCount < cellCount 
                                    && s < list.length; s++) {
                    if (cellCount - letterCount < 2 * minLength) {
                        minLength = cellCount - letterCount;
                    }
                    maxLength = Math.max(minLength, 
                        Math.min(maxLength, cellCount - letterCount - minLength));
                    var word:String = list[s];
                    if (minLength <= word.length && word.length <= maxLength) {
                        trace("Model.shuffleWords: " + word + " min " + minLength + " max " + maxLength);
                        words.push(word);
                        letterCount += word.length;
                    }
                }
            }
            if (cellCount < letterCount) {
                throw new Error("Expected exactly one letter for each cell.  Got " + letterCount + " letters for " + cellCount + " cells.");
            }
            return words;
        }

        /**
         * Set possibles at corners.
         * Randomly select cell from possibles to be a cursor.
         * Select a random neighbor to spell a word.
         * If no neighbor, select from possibles.
         */ 
        private function fillTable(words:Array, columnCount:int, rowCount:int):Array
        {
            var table:Array = [];
            var cellCount:int = columnCount * rowCount;
            for (var c:int = 0; c < cellCount; c++) {
                table.push(EMPTY);
            }
            for (var w:int = 0; w < words.length; w++) {
                var cursor:int = corner(table, columnCount, rowCount);
                for (var i:int = 0; i < words[w].length; i++) {
                    table[cursor] = words[w].substr(i, 1);
                    cursor = liberty(table, cursor, columnCount, rowCount);
                }
            }
            return table;
        }

        /**
         * Random with least neighbors.  Except, avoid isolated.
         */
        private function corner(table:Array, columnCount:int, rowCount:int):int
        {
            var neighborCounts:Array = [[], [], [], [], []];
            var cellCount:int = columnCount * rowCount;
            var n:int;
            var index:int = -1;
            for (var c:int = 0; c < cellCount; c++) {
                if (table[c] == EMPTY) {
                    // return c;
                    n = adjacents(table, c, columnCount, rowCount).length;
                    neighborCounts[n].push(c);
                }
            }
            neighborCounts.push(neighborCounts.shift());
            for (n = 0; n < neighborCounts.length; n++) {
                if (1 <= neighborCounts[n].length) {
                    shuffle(neighborCounts[n]);
                    index = neighborCounts[n][0];
                }
            }
            trace("Model.corner: " + index + " table <" + table + ">");
            return index;
        }

        private function adjacents(table:Array, cursor:int, columnCount:int, rowCount:int):Array
        {
            var neighbors:Array = [];
            var neighbor:int;
            if (columnCount <= cursor) {
                neighbor = cursor - columnCount;
                if (EMPTY == table[neighbor]) {
                    neighbors.push(neighbor);
                }
            }
            if (cursor < rowCount * (columnCount - 1)) {
                neighbor = cursor + columnCount;
                if (EMPTY == table[neighbor]) {
                    neighbors.push(neighbor);
                }
            }
            if (1 <= cursor % columnCount) {
                neighbor = cursor - 1;
                if (EMPTY == table[neighbor]) {
                    neighbors.push(neighbor);
                }
            }
            if (cursor % columnCount < columnCount - 1) {
                neighbor = cursor + 1;
                if (EMPTY == table[neighbor]) {
                    neighbors.push(neighbor);
                }
            }
            return neighbors;
        }

        private function liberty(table:Array, cursor:int, columnCount:int, rowCount:int):int
        {
            var neighbors:Array = adjacents(table, cursor, columnCount, rowCount);
            if (neighbors.length == 0) {
                return corner(table, columnCount, rowCount);
            }
            else {
                shuffle(neighbors);
                return neighbors[0];
            }
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
            var points:int = Math.pow(2, length - 3);
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
            round++;
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
            else if (occupied(table) < LETTER_MIN) {
                winning = -1;
            }
            return winning;
        }
        
        private function occupied(table:Array):int
        {
            var count:int = 0;
            for (var c:int = 0; c < table.length; c++) {
                if (EMPTY != table[c]) {
                    count++;
                }
            }
            return count;
        }
    }
}
