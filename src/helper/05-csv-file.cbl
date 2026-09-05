      ******************************************************************
      * CSV-FILE                                                       *
      *                                                                *
      * Data in a flat text file: ORGANIZATION LINE SEQUENTIAL.        *
      * COBOL has no CSV support -- a line is just PIC X(n). Building  *
      * the line is STRING, taking it apart again is UNSTRING.         *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CSV-FILE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      * Logical file name inside the program, path outside of it.
           SELECT ITEM-FILE ASSIGN TO "data/items.csv"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS  IS WS-STATUS.

       DATA DIVISION.
       FILE SECTION.
      * The record buffer -- one line of the file lives here.
       FD  ITEM-FILE.
       01  ITEM-RECORD            PIC X(80).

       WORKING-STORAGE SECTION.
      * Two digits after every I/O operation: "00" means success.
       01  WS-STATUS              PIC XX.
       01  WS-EOF                 PIC X         VALUE "N".

      * One warehouse item as the program wants to work with it.
       01  WS-ITEM.
           05  WS-ID              PIC X(6).
           05  WS-NAME            PIC X(20).
           05  WS-QTY             PIC 9(5).
           05  WS-PRICE           PIC 9(5)V99.

      * Edited copies -- digits become text before they hit the line.
       01  WS-QTY-TEXT            PIC Z(4)9.
       01  WS-PRICE-TEXT          PIC Z(4)9.99.

      * The four raw fields as they come back out of a line.
       01  WS-IN.
           05  WS-IN-ID           PIC X(10).
           05  WS-IN-NAME         PIC X(20).
           05  WS-IN-QTY          PIC X(10).
           05  WS-IN-PRICE        PIC X(10).

       01  WS-LINE-VALUE          PIC 9(7)V99   VALUE ZERO.
       01  WS-TOTAL               PIC 9(7)V99   VALUE ZERO.
       01  WS-MONEY               PIC ZZZ,ZZ9.99.

       PROCEDURE DIVISION.
       MAIN-PARA.
           PERFORM WRITE-FILE
           PERFORM READ-FILE
           STOP RUN.

      * ---- writing -------------------------------------------------
       WRITE-FILE.
           OPEN OUTPUT ITEM-FILE
           IF WS-STATUS NOT = "00"
               DISPLAY "cannot open for output, status " WS-STATUS
               STOP RUN
           END-IF
           MOVE "A-100"       TO WS-ID
           MOVE "Hex bolt M8" TO WS-NAME
           MOVE 120           TO WS-QTY
           MOVE 0.35          TO WS-PRICE
           PERFORM WRITE-ONE
           MOVE "A-101"       TO WS-ID
           MOVE "Washer 8mm"  TO WS-NAME
           MOVE 4300          TO WS-QTY
           MOVE 0.02          TO WS-PRICE
           PERFORM WRITE-ONE
           MOVE "B-200"       TO WS-ID
           MOVE "Gear wheel"  TO WS-NAME
           MOVE 17            TO WS-QTY
           MOVE 89.90         TO WS-PRICE
           PERFORM WRITE-ONE
           CLOSE ITEM-FILE
           DISPLAY "written: data/items.csv".

       WRITE-ONE.
           MOVE WS-QTY   TO WS-QTY-TEXT
           MOVE WS-PRICE TO WS-PRICE-TEXT
           MOVE SPACES   TO ITEM-RECORD
           STRING FUNCTION TRIM(WS-ID)         ","
                  FUNCTION TRIM(WS-NAME)       ","
                  FUNCTION TRIM(WS-QTY-TEXT)   ","
                  FUNCTION TRIM(WS-PRICE-TEXT)
               DELIMITED BY SIZE INTO ITEM-RECORD
           END-STRING
           WRITE ITEM-RECORD.

      * ---- reading -------------------------------------------------
       READ-FILE.
           OPEN INPUT ITEM-FILE
           DISPLAY " "
           DISPLAY "ID     NAME                   QTY      VALUE"
           DISPLAY "-------------------------------------------"
           PERFORM UNTIL WS-EOF = "Y"
               READ ITEM-FILE
                   AT END     MOVE "Y" TO WS-EOF
                   NOT AT END PERFORM SHOW-ONE
               END-READ
           END-PERFORM
           CLOSE ITEM-FILE
           MOVE WS-TOTAL TO WS-MONEY
           DISPLAY "-------------------------------------------"
           DISPLAY "total stock value              " WS-MONEY.

       SHOW-ONE.
           MOVE SPACES TO WS-IN
           UNSTRING ITEM-RECORD DELIMITED BY ","
               INTO WS-IN-ID WS-IN-NAME WS-IN-QTY WS-IN-PRICE
           END-UNSTRING
      *    Text back to numbers -- NUMVAL is the safe way in.
           COMPUTE WS-LINE-VALUE ROUNDED =
               FUNCTION NUMVAL(WS-IN-QTY) * FUNCTION NUMVAL(WS-IN-PRICE)
           ADD WS-LINE-VALUE TO WS-TOTAL
           MOVE WS-LINE-VALUE TO WS-MONEY
           DISPLAY WS-IN-ID(1:6) " " WS-IN-NAME " "
                   WS-IN-QTY(1:5) " " WS-MONEY.
