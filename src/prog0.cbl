      * Strings Concats

       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROG0.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  VAR0                   PIC X(13) VALUE 'A'.
       01  VAR1                   PIC X(13) VALUE 'B'.
       01  VAR2                   PIC X(13) VALUE ' '.
       01  VAR3                   PIC X(26) VALUE 'D'.
       01  VHELLO                 PIC X(13) VALUE 'Hello'.
       01  VWORLD                 PIC X(13) VALUE 'World'.

       PROCEDURE DIVISION.
       MAIN-PARAGRAPH.
           DISPLAY VAR0
           MOVE VAR0 TO VAR2
           DISPLAY VAR2
           MOVE VAR0 TO VAR1
           DISPLAY VAR1
           *> VAR0 DELIMITED BY SPACE INTO VAR3
           MOVE FUNCTION CONCATENATE(VAR0, VAR1) TO VAR2.
           DISPLAY VAR2
           MOVE FUNCTION CONCATENATE(VHELLO, VWORLD) TO VAR3.
           DISPLAY VAR3
           STOP RUN.

       END PROGRAM PROG0.
