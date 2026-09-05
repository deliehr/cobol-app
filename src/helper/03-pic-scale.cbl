      ******************************************************************
      * PIC-SCALE                                                      *
      *                                                                *
      * What V really does: it consumes no byte, it only fixes where   *
      * the decimal point is assumed. REDEFINES lets us look at the    *
      * raw bytes behind each field.                                   *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PIC-SCALE.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Three digits before, three after -- 6 bytes, no point stored.
       01  WS-A                   PIC 9(3)V9(3) VALUE 12.34.
       01  WS-A-RAW REDEFINES WS-A PIC X(6).
      * Same value, five decimals -- 8 bytes.
       01  WS-B                   PIC 9(3)V9(5) VALUE 12.34.
       01  WS-B-RAW REDEFINES WS-B PIC X(8).
      * Trailing V: point sits behind the last digit. 3 bytes.
       01  WS-C                   PIC 9(3)V      VALUE 12.
       01  WS-C-RAW REDEFINES WS-C PIC X(3).
      * No V at all -- byte-identical to WS-C, but a different type.
       01  WS-D                   PIC 9(3)       VALUE 12.
       01  WS-D-RAW REDEFINES WS-D PIC X(3).
      * Leading V: pure fraction, nothing before the point.
       01  WS-E                   PIC V9(3)      VALUE 0.125.
       01  WS-E-RAW REDEFINES WS-E PIC X(3).
      * A V-less field may go to alphanumeric; a scaled one may not.
       01  WS-TEXT                PIC X(6)       VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PARAGRAPH.
           PERFORM SHOW-LAYOUT
           PERFORM SHOW-MOVE-RULE
           STOP RUN.

       SHOW-LAYOUT.
           DISPLAY 'picture        bytes  displayed   raw buffer'
           DISPLAY '9(3)V9(3)  ' FUNCTION LENGTH(WS-A)
                   '      [' WS-A ']    [' WS-A-RAW ']'
           DISPLAY '9(3)V9(5)  ' FUNCTION LENGTH(WS-B)
                   '      [' WS-B ']  [' WS-B-RAW ']'
           DISPLAY '9(3)V      ' FUNCTION LENGTH(WS-C)
                   '      [' WS-C ']       [' WS-C-RAW ']'
           DISPLAY '9(3)       ' FUNCTION LENGTH(WS-D)
                   '      [' WS-D ']       [' WS-D-RAW ']'
           DISPLAY 'V9(3)      ' FUNCTION LENGTH(WS-E)
                   '      [' WS-E ']    [' WS-E-RAW ']'.

       SHOW-MOVE-RULE.
           MOVE WS-D TO WS-TEXT
           DISPLAY ' '
           DISPLAY 'MOVE 9(3) TO X(6) -> [' WS-TEXT ']'
           DISPLAY 'MOVE 9(3)V9(3) TO X(6) -> rejected at compile time'.

       END PROGRAM PIC-SCALE.
