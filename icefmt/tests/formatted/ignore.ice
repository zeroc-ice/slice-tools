// Copyright (c) ZeroC, Inc.

module Demo
{
    // Formatting leaves the definitions between these two comments as written.
    // icefmt: off
    const int    One   = 1;
    const int    Eleven = 11;
    // icefmt: on
    const int Twelve = 12;

    interface Printer
    {
        // icefmt: ignore
        void print(string  document,
                   int     copies);

        void stop(string user, bool notify);
    }

    enum Color
    {
        // icefmt: off

        Red     = 1,
        Green   = 2,
        // Without the comment that turns formatting on, it stays off to the end of the body.
        Blue    = 3
    }

    // The comma that follows an enumerator stays with it, and so does the comment after the comma.
    enum Level
    {
        Low = 1,
        // icefmt: ignore
        Medium  =  2,
        // icefmt: ignore
        High    =  3  ,  // the top
        // icefmt: ignore
        Maximum =  4
    }

    // A comment that turns formatting on right after the one that turns it off leaves nothing as written.
    // icefmt: off
    // icefmt: on
    struct Point { int x; int y; }

    // Only a "//" comment on a line of its own counts.
    /// icefmt: ignore
    const int Documented = 1;
    /* icefmt: off */
    const int Blocked = 2;
    const int Trailed = 3; // icefmt: off
    const int Next = 4;

    // What follows the comment stays as written: a blank line, a doc comment, metadata, the semicolon after a closing
    // brace, and the comment that ends the line.
    // icefmt: ignore

    /// A size.
    ["deprecated"]   struct  Size  {  int  width;  int  height;  };   // kept

    // A doc comment after text left as written, on its last line, stays there.
    struct Margins
    {
        // icefmt: ignore
        int   left;   /// The left margin.
        // icefmt: off
        int   top;   /// The top margin.
        int   bottom;   /// The bottom margin.
        // icefmt: on
        /// The right margin.
        int right;
    }

    enum Side
    {
        // icefmt: ignore
        Left  =  1,   /// The left side.
        Right = 2
    }

    struct Indented
    {
        // The lines keep the indentation they have beyond the first one, a tab included.
        // icefmt: off
        int   first;   int   second;
        	int   third;
        int   fourth;
        // icefmt: on
        int fifth;
    }
}

// Formatting stays off to the end of the file.
// icefmt: off
module  Last  {  }
