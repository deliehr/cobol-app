      * Numbers

       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROG1.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  VAR0                   PIC S9(5) VALUE 5.
       01  VAR1                   PIC S9(5) VALUE -1.
       01  VAR2                   PIC S9(5).
       01  VAR3                   PIC S9(2) VALUE 99.
       01  VAR4                   PIC S9(1).
       01  VAR5                   PIC 9(1).

       PROCEDURE DIVISION.
       MAIN-PARAGRAPH.
           DISPLAY VAR0
           DISPLAY VAR1
           DISPLAY VAR2
           ADD VAR0 TO VAR1 GIVING VAR2
           DISPLAY VAR2
           MOVE VAR3 TO VAR4
           DISPLAY VAR4
           COMPUTE VAR5 = VAR0 - VAR3
           DISPLAY VAR5

           STOP RUN.

       END PROGRAM PROG1.
