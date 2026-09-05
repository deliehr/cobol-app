      ******************************************************************
      * SCREEN-DEMO                                                    *
      *                                                                *
      * Side quest: COBOL is not limited to line-by-line STDOUT.       *
      * The SCREEN SECTION is standard COBOL for full-screen forms --  *
      * the 3270 terminal masks of the mainframe world. GnuCOBOL maps  *
      * it onto ncurses, so the same source runs in a Mac terminal.    *
      *                                                                *
      * Run it in a real terminal (not through a pipe):  make run      *
      * MAIN=screen-demo                                               *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SCREEN-DEMO.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CRT STATUS IS WS-KEY.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CUSTOMER.
           05  WS-NAME            PIC X(20) VALUE SPACES.
           05  WS-BALANCE         PIC 9(5)V99 VALUE ZERO.
       01  WS-KEY                 PIC 9(4) VALUE ZERO.
           88  KEY-ESCAPE         VALUE 2005.

       SCREEN SECTION.
       01  SC-CUSTOMER-FORM.
           05  BLANK SCREEN.
           05  LINE 2 COL 5 VALUE 'CUSTOMER MAINTENANCE'
               FOREGROUND-COLOR 7 BACKGROUND-COLOR 4.
           05  LINE 4 COL 5 VALUE 'Name    :'.
           05  LINE 4 COL 15 PIC X(20) USING WS-NAME
               REVERSE-VIDEO AUTO.
           05  LINE 5 COL 5 VALUE 'Balance :'.
           05  LINE 5 COL 15 PIC 9(5)V99 USING WS-BALANCE
               REVERSE-VIDEO.
           05  LINE 7 COL 5 VALUE 'ENTER = accept    ESC = cancel'.

       PROCEDURE DIVISION.
       MAIN-PARAGRAPH.
           DISPLAY SC-CUSTOMER-FORM
           ACCEPT SC-CUSTOMER-FORM
           PERFORM REPORT-RESULT
           STOP RUN.

       REPORT-RESULT.
           IF KEY-ESCAPE
               DISPLAY 'cancelled by user'
           ELSE
               DISPLAY 'name    [' WS-NAME ']'
               DISPLAY 'balance [' WS-BALANCE ']'
           END-IF.

       END PROGRAM SCREEN-DEMO.
