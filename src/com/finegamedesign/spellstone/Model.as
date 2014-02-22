package com.finegamedesign.spellstone
{
    public class Model
    {
        internal static const EMPTY:String = " ";
        internal static const LETTER_MAX:int = 8;

        internal static var levels:Array = [
            {columnCount: 5, rowCount: 1, diagram: "START"},
            {columnCount: 3, rowCount: 2},
            {columnCount: 3, rowCount: 3},
            {columnCount: 4, rowCount: 3},
            {columnCount: 5, rowCount: 3},
            {columnCount: 5, rowCount: 4},
            {columnCount: 6, rowCount: 4},
            {columnCount: 7, rowCount: 5}
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
                for (var c:int = 0; c < cellCount; c++) {
                    var letter:String;
                    table.push(letter);
                }
                shuffle(table);
            }
            selected = [];
            kill = 0;
            restartScore = score;
            maxKill = columnCount * rowCount;
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

        /**
         * Removed addresses if 3 or more.
         * Set index to EMPTY and cell to null, in case view still refers to cell.
         */
        internal function judge():Array
        {
            var selectedMin:int = 3;
            var removed:Array = [];
            if (selectedMin <= selected.length) {
                removed = selected.slice();
                // trace("Model.judge: removed " + removed);
                for each(var address:int in removed) {
                    table[address] = EMPTY;
                }
                scoreUp(removed.length);
                if (null != onDie) {
                    onDie();
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
