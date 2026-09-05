      ******************************************************************
      * INDEXED-FILE                                                   *
      *                                                                *
      * The native COBOL "database": ORGANIZATION INDEXED (ISAM).      *
      * Fixed record layout, a RECORD KEY, and keyed access -- READ,   *
      * REWRITE, DELETE, plus START/READ NEXT for ordered walking.     *
      * The OPEN mode decides what happens to existing data.           *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. INDEXED-FILE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ITEM-FILE ASSIGN TO "data/items.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS DYNAMIC
               RECORD KEY   IS IT-ID
               FILE STATUS  IS WS-STATUS.

       DATA DIVISION.
       FILE SECTION.
      * No parsing anywhere: the record IS the structure on disk.
       FD  ITEM-FILE.
       01  ITEM-RECORD.
           05  IT-ID              PIC X(6).
           05  IT-NAME            PIC X(20).
           05  IT-QTY             PIC 9(5).
           05  IT-PRICE           PIC 9(5)V99.

       WORKING-STORAGE SECTION.
       01  WS-STATUS              PIC XX.
       01  WS-EOF                 PIC X         VALUE "N".
       01  WS-MONEY               PIC ZZZ,ZZ9.99.
       01  WS-COUNT               PIC ZZZ9.

       PROCEDURE DIVISION.
       MAIN-PARA.
           PERFORM ENSURE-FILE
           PERFORM READ-BY-KEY
           PERFORM BOOK-IN
           PERFORM MISSING-KEY
           PERFORM WALK-FILE
           STOP RUN.

      * ---- OUTPUT wipes, so only build the file when it is absent ---
       ENSURE-FILE.
           OPEN INPUT ITEM-FILE
           IF WS-STATUS = "35"
               PERFORM LOAD-FILE
           ELSE
               CLOSE ITEM-FILE
               DISPLAY "data/items.dat exists -- keeping the stock"
           END-IF.

      * ---- create the file, records in random order -----------------
       LOAD-FILE.
           OPEN OUTPUT ITEM-FILE
           MOVE "B-200" TO IT-ID
           MOVE "Gear wheel"  TO IT-NAME
           MOVE 17    TO IT-QTY
           MOVE 89.90 TO IT-PRICE
           PERFORM WRITE-ONE
           MOVE "A-100" TO IT-ID
           MOVE "Hex bolt M8" TO IT-NAME
           MOVE 120   TO IT-QTY
           MOVE 0.35  TO IT-PRICE
           PERFORM WRITE-ONE
           MOVE "A-101" TO IT-ID
           MOVE "Washer 8mm"  TO IT-NAME
           MOVE 4300  TO IT-QTY
           MOVE 0.02  TO IT-PRICE
           PERFORM WRITE-ONE
           CLOSE ITEM-FILE
           DISPLAY "loaded 3 records into data/items.dat".

       WRITE-ONE.
           WRITE ITEM-RECORD
               INVALID KEY DISPLAY "duplicate key " IT-ID
           END-WRITE.

      * ---- one record, straight by its key --------------------------
       READ-BY-KEY.
           OPEN I-O ITEM-FILE
           MOVE "A-101" TO IT-ID
           READ ITEM-FILE KEY IS IT-ID
               INVALID KEY DISPLAY "not found"
           END-READ
           DISPLAY " "
           DISPLAY "lookup A-101 -> " FUNCTION TRIM(IT-NAME)
                   ", qty " IT-QTY.

      * ---- change that record in place ------------------------------
       BOOK-IN.
           ADD 500 TO IT-QTY
           REWRITE ITEM-RECORD
               INVALID KEY DISPLAY "rewrite failed " WS-STATUS
           END-REWRITE
           DISPLAY "booked in 500 -> qty now " IT-QTY.

      * ---- a key that is not there ----------------------------------
       MISSING-KEY.
           MOVE "Z-999" TO IT-ID
           READ ITEM-FILE KEY IS IT-ID
               INVALID KEY
                   DISPLAY "lookup Z-999 -> status " WS-STATUS
           END-READ.

      * ---- walk everything, always in key order ---------------------
       WALK-FILE.
           MOVE LOW-VALUES TO IT-ID
           START ITEM-FILE KEY IS GREATER THAN IT-ID
               INVALID KEY DISPLAY "file is empty"
           END-START
           DISPLAY " "
           DISPLAY "ID     NAME                   QTY      VALUE"
           DISPLAY "-------------------------------------------"
           PERFORM UNTIL WS-EOF = "Y"
               READ ITEM-FILE NEXT RECORD
                   AT END     MOVE "Y" TO WS-EOF
                   NOT AT END PERFORM SHOW-ONE
               END-READ
           END-PERFORM
           CLOSE ITEM-FILE.

       SHOW-ONE.
           COMPUTE WS-MONEY ROUNDED = IT-QTY * IT-PRICE
           MOVE IT-QTY TO WS-COUNT
           DISPLAY IT-ID " " IT-NAME " " WS-COUNT " " WS-MONEY.
