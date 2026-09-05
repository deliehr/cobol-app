      ******************************************************************
      * ARITHMETIC                                                     *
      *                                                                *
      * Third step: decimal arithmetic. COMPUTE against the verb       *
      * forms (ADD / SUBTRACT / MULTIPLY / DIVIDE), truncation versus  *
      * ROUNDED, the ON SIZE ERROR guard, and DIVIDE ... REMAINDER.    *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ARITHMETIC.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * One invoice: net amount, tax rate, and the derived fields.
       01  WS-INVOICE.
           05  WS-NET             PIC 9(5)V99  VALUE 1234.56.
           05  WS-VAT-RATE        PIC 9V9(4)   VALUE 0.1900.
           05  WS-VAT             PIC 9(5)V99  VALUE ZERO.
           05  WS-GROSS           PIC 9(5)V99  VALUE ZERO.
      * Same computation, one decimal place -- truncated vs ROUNDED.
       01  WS-TRUNCATED           PIC 9(5)V9   VALUE ZERO.
       01  WS-ROUNDED             PIC 9(5)V9   VALUE ZERO.
      * Deliberately too small to hold the result.
       01  WS-SMALL               PIC 9(3)V99  VALUE ZERO.
      * Splitting an amount into equal shares.
       01  WS-TOTAL               PIC 9(7)V99  VALUE 1000.00.
       01  WS-PARTS               PIC 9(3)     VALUE 3.
       01  WS-SHARE               PIC 9(5)V99  VALUE ZERO.
       01  WS-REST                PIC 9(5)V99  VALUE ZERO.
      * Output formatting only -- never an operand of arithmetic.
       01  WS-EDITED              PIC ZZZ,ZZ9.99.
       01  WS-EDITED-1            PIC ZZZ,ZZ9.9.

       PROCEDURE DIVISION.
       MAIN-PARAGRAPH.
           PERFORM SHOW-INVOICE
           PERFORM SHOW-ROUNDING
           PERFORM SHOW-SIZE-ERROR
           PERFORM SHOW-SHARES
           STOP RUN.

      * COMPUTE takes an expression; the verb forms take operands.
       SHOW-INVOICE.
           COMPUTE WS-VAT ROUNDED = WS-NET * WS-VAT-RATE
           ADD WS-NET TO WS-VAT GIVING WS-GROSS
           DISPLAY '--- invoice ---'
           MOVE WS-NET TO WS-EDITED
           DISPLAY 'net        ' WS-EDITED
           DISPLAY 'rate       ' WS-VAT-RATE
           MOVE WS-VAT TO WS-EDITED
           DISPLAY 'vat        ' WS-EDITED '   (rounded)'
           MOVE WS-GROSS TO WS-EDITED
           DISPLAY 'gross      ' WS-EDITED.

      * The exact product is 234.5664 -- what happens to the tail?
       SHOW-ROUNDING.
           COMPUTE WS-TRUNCATED = WS-NET * WS-VAT-RATE
           COMPUTE WS-ROUNDED ROUNDED = WS-NET * WS-VAT-RATE
           DISPLAY ' '
           DISPLAY '--- 234.5664 into PIC 9(5)V9 ---'
           MOVE WS-TRUNCATED TO WS-EDITED-1
           DISPLAY 'default    ' WS-EDITED-1 '     (truncated)'
           MOVE WS-ROUNDED TO WS-EDITED-1
           DISPLAY 'ROUNDED    ' WS-EDITED-1.

      * A result too large for the target: guarded and unguarded.
       SHOW-SIZE-ERROR.
           DISPLAY ' '
           DISPLAY '--- 1234.56 into PIC 9(3)V99 ---'
           COMPUTE WS-SMALL = WS-NET
               ON SIZE ERROR
                   DISPLAY 'guarded    result rejected, field unchanged'
           END-COMPUTE
           MOVE WS-SMALL TO WS-EDITED
           DISPLAY 'value now  ' WS-EDITED
           MOVE WS-NET TO WS-SMALL
           MOVE WS-SMALL TO WS-EDITED
           DISPLAY 'via MOVE   ' WS-EDITED '   (silently cut)'.

      * Classic money split: the remainder must not disappear.
       SHOW-SHARES.
           DIVIDE WS-TOTAL BY WS-PARTS GIVING WS-SHARE
               REMAINDER WS-REST
           DISPLAY ' '
           DISPLAY '--- 1000.00 split 3 ways ---'
           MOVE WS-SHARE TO WS-EDITED
           DISPLAY 'share      ' WS-EDITED
           MOVE WS-REST TO WS-EDITED
           DISPLAY 'remainder  ' WS-EDITED.

       END PROGRAM ARITHMETIC.
