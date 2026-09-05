      ******************************************************************
      * PIC-BASICS                                                     *
      *                                                                *
      * Second step: variables, PICTURE clauses and terminal input.    *
      * Reads a customer name and a balance from STDIN, then shows     *
      * how the values are really stored -- raw and edited.            *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PIC-BASICS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * A group item: one record built from several elementary fields.
       01  WS-CUSTOMER.
           05  WS-NAME            PIC X(20).
           05  WS-BALANCE         PIC 9(5)V99.
      * Edited field: only for output, never for arithmetic.
       01  WS-BALANCE-EDITED      PIC ZZ,ZZ9.99.

       PROCEDURE DIVISION.
       MAIN-PARAGRAPH.
           PERFORM READ-CUSTOMER
           PERFORM SHOW-CUSTOMER
           STOP RUN.

       READ-CUSTOMER.
           DISPLAY 'Name    : ' WITH NO ADVANCING
           ACCEPT WS-NAME
           DISPLAY 'Balance : ' WITH NO ADVANCING
           ACCEPT WS-BALANCE.

       SHOW-CUSTOMER.
           MOVE WS-BALANCE TO WS-BALANCE-EDITED
           DISPLAY ' '
           DISPLAY 'name  raw    [' WS-NAME ']'
           DISPLAY 'money raw    [' WS-BALANCE ']'
           DISPLAY 'money edited [' WS-BALANCE-EDITED ']'
           DISPLAY 'record raw   [' WS-CUSTOMER ']'.

       END PROGRAM PIC-BASICS.
