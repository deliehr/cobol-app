      ******************************************************************
      * HELLO-WORLD                                                    *
      *                                                                *
      * The classic first COBOL program: prints a greeting to STDOUT.  *
      * Written in fixed-format COBOL (the layout you find in real     *
      * mainframe sources), so the column rules apply:                 *
      *                                                                *
      *   cols 1-6   sequence numbers (historically punch card no.)    *
      *   col  7     indicator area ('*' = comment, '-' = continuation)*
      *   cols 8-11  area A  (divisions, sections, paragraphs)         *
      *   cols 12-72 area B  (statements)                              *
      *   cols 73-80 ignored (historically the card identifier)        *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO-WORLD.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-GREETING            PIC X(13) VALUE 'Hello, World!'.

       PROCEDURE DIVISION.
       MAIN-PARAGRAPH.
           DISPLAY WS-GREETING
           STOP RUN.

       END PROGRAM HELLO-WORLD.
