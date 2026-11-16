// Copyright (c) ZeroC, Inc.

module Demo
{
    // Formatting leaves the definitions between these two comments as written.
    // ice-fmt: off
    const int    One   = 1;
    const int    Eleven = 11;
    // ice-fmt: on
    const int    Twelve = 12;

    interface Printer
    {
        // ice-fmt: ignore
        void print(string  document,
                   int     copies);

        void stop(string  user,
            bool notify);
    }

    enum Color
    {
        // ice-fmt: off

        Red     = 1,
        Green   = 2,
        // Without the comment that turns formatting on, it stays off to the end of the body.
        Blue    = 3
    }

    // The comma that follows an enumerator stays with it, and so does the comment after the comma.
    enum Level
    {
        Low     = 1,
        // ice-fmt: ignore
        Medium  =  2,
        // ice-fmt: ignore
        High    =  3  ,  // the top
        // ice-fmt: ignore
        Maximum =  4
    }

    // A comment that turns formatting on right after the one that turns it off leaves nothing as written.
    // ice-fmt: off
    // ice-fmt: on
    struct  Point  {  int  x;  int  y;  }

    // Only a "//" comment on a line of its own counts.
    /// ice-fmt: ignore
    const  int  Documented  =  1;
    /* ice-fmt: off */
    const  int  Blocked  =  2;
    const  int  Trailed  =  3;   // ice-fmt: off
    const  int  Next  =  4;

    // What follows the comment stays as written: a blank line, a doc comment, metadata, the semicolon after a closing
    // brace, and the comment that ends the line.
    // ice-fmt: ignore

    /// A size.
    ["deprecated"]   struct  Size  {  int  width;  int  height;  };   // kept

    struct Indented
    {
            // The lines keep the indentation they have beyond the first one, a tab included.
            // ice-fmt: off
            int   first;   int   second;
            	int   third;
        int   fourth;
            // ice-fmt: on
            int   fifth;
    }
}

// Formatting stays off to the end of the file.
// ice-fmt: off
module  Last  {  }
