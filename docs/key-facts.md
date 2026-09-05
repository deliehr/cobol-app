# Key Facts

Meine eigenen Notizen zu COBOL — in meinen Worten festgehalten.

> Diese Datei enthält **ausschließlich Inhalte von mir (Dominik)**. Claude fügt
> hier nichts von sich aus hinzu und formuliert nichts um; Ergänzungen nur auf
> ausdrückliche Ansage.

1. Vier Divisionen: Name des Programms, Environments, Variablen, Methoden.
2. `PIC 9(7)V99` rechnet dezimal-exakt, Java wäre `BigDecimal`.
3. `DISPLAY` schreibt nach STDOUT.
4. Paragraphen-Namen sind frei wählbar, aber vermutlich längenbeschränkt (30 Zeichen).
5. Es gibt tatsächlich Satzabschlüsse wie den Punkt.
6. Fixed Format, Spaltenregel, Lochkarten -> Von Maschinen einlesbar.
7. GnuCOBOL kann Free Format.
8. Variablen werden aufgefüllt, siehe prog0
9. Zahlen mit Vorzeichen: S (Signed), siehe prog1
10. Wenn abgeschnitten wird, dann zuerst Einerstelle, Zehnerstelle, es gibt eine Ausrichtung. Strings X wird von links ausgerichtet, also X(5) -> X(2), ABCDE -> AB. Bei Zahlen zählt der Dezimalpunkt V. Ganzzahlen kann man sich mit virtuellen Dezimalpunkt vorstellen, also wird von rechts nach links abgeschnitten. 