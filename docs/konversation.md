# Konversationsprotokoll

Fortlaufendes Log der Tutor-Sessions zu diesem Projekt. Neueste Session unten
anfügen. Zweck: das erarbeitete COBOL-Wissen bleibt nachlesbar, unabhängig vom
Chat-Verlauf.

---

## Session 1 — 2026-09-03 — Setup und Hello World

### Auftrag

> Sei für mich ein Cobol-Tutor, der mir die Grundstruktur und Basis-Wissen über
> Cobol vermittelt. Ich möchte eine minimale Anwendung schreiben und diese später
> nach Java konvertieren. Lege auch eine Claude.md an. Du sollst prinzipiell den
> Code erstmal schreiben und mir dann erklären. Wichtig ist, dass ich das Cobol
> Programm auf meinem Mac ausführen kann. Zu allerst erst möchte ich das typische
> Hello-World Programm entwickeln.

Nachgereicht:

> Und schreibe eine Projekt README

> Git Commits schreibe und pushe ich, bitte in die CLaude.md übernehmen

### Was gemacht wurde

1. Geprüft: kein COBOL-Compiler vorhanden. `brew install gnucobol` →
   **GnuCOBOL 3.2.0** unter `/opt/homebrew/bin/cobc`.
2. `src/hello-world.cbl` geschrieben (Fixed Format).
3. `Makefile`, `.gitignore`, `CLAUDE.md`, `README.md` angelegt.
4. `make run` → Ausgabe `Hello, World!`, Build warnungsfrei mit `-Wall`.

Zwei Korrekturen unterwegs, beide lehrreich:

- Eine Kommentarzeile war auf 73 Zeichen gerutscht — jenseits von Spalte 72
  schneidet der Compiler stillschweigend ab.
- `AUTHOR. DOMINIK LIEHR.` in der IDENTIFICATION DIVISION erzeugte
  `warning: AUTHOR is obsolete in GnuCOBOL`. Die Klausel stammt aus COBOL-85 und
  früher; entfernt, damit der Build warnungsfrei bleibt.

Keine Git-Operationen ausgeführt — Commits und Pushes macht der Nutzer selbst.

### Der Code

```cobol
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
```

### Erklärung

#### COBOL ist in DIVISIONs gegliedert

Das ist *die* Grundstruktur. Jedes COBOL-Programm besteht aus bis zu vier
DIVISIONs, immer in dieser Reihenfolge:

| DIVISION         | Zweck                                             | Java-Analogie              |
| ---------------- | ------------------------------------------------- | -------------------------- |
| `IDENTIFICATION` | Wie heißt das Programm?                           | `class Foo {`              |
| `ENVIRONMENT`    | Welche externen Ressourcen (Dateien, Terminal)?   | Config, Ressourcen-Pfade   |
| `DATA`           | Alle Variablen — **vollständig vorab deklariert** | Felder der Klasse          |
| `PROCEDURE`      | Der ausführbare Code                              | Methodenkörper             |

`ENVIRONMENT DIVISION` fehlt hier, weil noch keine Dateien im Spiel sind — sie
ist optional. `IDENTIFICATION` und `PROCEDURE` sind praktisch immer da.

Wichtigster konzeptioneller Unterschied zu Java: **es gibt keine lokalen
Variablen mitten im Code.** Alles, was das Programm an Daten braucht, steht oben
in der `DATA DIVISION`. COBOL wurde für Maschinen entworfen, bei denen der
Speicherbedarf zur Compile-Zeit feststehen musste. Diese Trennung „Daten hier
oben, Logik da unten" durchzieht die ganze Sprache.

#### `WORKING-STORAGE SECTION`

Bereich für Variablen, die über die gesamte Programmlaufzeit leben. In
Java-Begriffen: statische Felder — einmal beim Programmstart angelegt, behalten
ihren Wert.

#### Die Zeile, die COBOL ausmacht

```cobol
       01  WS-GREETING            PIC X(13) VALUE 'Hello, World!'.
```

Vier Bestandteile:

- **`01`** — die *Level Number*. COBOL-Daten sind hierarchisch: `01` ist die
  oberste Ebene, `05`, `10`, `15` sind untergeordnete Felder. Damit baut man
  Strukturen (Thema Gruppenfelder).
- **`WS-GREETING`** — der Name. `WS-`-Präfix als Konvention für
  WORKING-STORAGE, damit beim Lesen klar ist, wo das Feld herkommt. Bindestriche
  statt Unterstriche, weil COBOL keine Unterstriche in Bezeichnern kennt.
- **`PIC X(13)`** — die *PICTURE-Klausel*, das Typsystem von COBOL. `X` = ein
  beliebiges Zeichen, `(13)` = 13 davon. Das ist **kein** `String`, sondern ein
  Puffer fester Breite von genau 13 Zeichen. Kürzere Werte werden rechts mit
  Leerzeichen aufgefüllt, längere abgeschnitten — ohne Fehlermeldung.
- **`VALUE '...'`** — der Initialwert.

Weitere PICTURE-Typen: `9` für eine Ziffer (`PIC 9(5)` = fünfstellige Zahl), `V`
für den gedachten Dezimalpunkt (`PIC 9(7)V99` = sieben Vorkomma-, zwei
Nachkommastellen), `S` für ein Vorzeichen.

Für die Java-Konvertierung schon jetzt merken: `PIC 9(7)V99` rechnet
**dezimal-exakt**. Das Java-Gegenstück ist `BigDecimal`, nie `double`. Genau
daran scheitern Migrationen von Finanzsoftware.

#### `PROCEDURE DIVISION`

```cobol
       MAIN-PARAGRAPH.
           DISPLAY WS-GREETING
           STOP RUN.
```

`MAIN-PARAGRAPH.` ist ein *Paragraph* — ein benannter Codeblock, aufrufbar per
`PERFORM MAIN-PARAGRAPH`. COBOLs Version einer Methode, allerdings ohne
Parameter und ohne Rückgabewert. Der Name ist frei wählbar; `MAIN-PARAGRAPH`
oder `MAIN-PROCEDURE` ist üblich.

`DISPLAY` schreibt nach STDOUT. `STOP RUN` beendet das Programm und gibt die
Kontrolle ans Betriebssystem zurück — ohne das läuft der Code in den nächsten
Paragraph hinein.

Zu den **Punkten**: Der Punkt ist in COBOL der Satzabschluss, nicht das
Semikolon pro Statement. `DISPLAY WS-GREETING` hat keinen Punkt, `STOP RUN.`
schon — der Punkt beendet den ganzen Satz aus beiden Anweisungen. Klassische
Fehlerquelle: ein Punkt zu früh, und ein `IF`-Block endet dort, wo man es nicht
wollte.

#### Die Spaltenregeln (Fixed Format)

Klassisches COBOL erbt sein Layout von der Lochkarte, die Spaltenposition ist
**bedeutungstragend**:

```
Spalte:  1----6 7 8---11 12----------------------------------72 73----80
         Seq.   │ Area A Area B                                 ignoriert
                Indikator
```

- **7** — `*` macht die Zeile zum Kommentar, `-` setzt ein Literal fort
- **8–11** (Area A) — DIVISION- und SECTION-Köpfe, Paragraph-Namen, `01`-Level
- **12–72** (Area B) — alle Anweisungen
- **ab 73** — wird stillschweigend ignoriert

Deshalb beginnen `IDENTIFICATION DIVISION.` und `MAIN-PARAGRAPH.` bei Spalte 8,
`DISPLAY` aber bei Spalte 12.

GnuCOBOL kann auch Free Format (`-fformat=free`), wo die Regeln wegfallen.
Bewusst Fixed Format gewählt: wenn das Ziel Migration nach Java ist, trifft man
auf echten Legacy-Code, und der ist Fixed Format.

Spaltenprüfung:

```bash
awk 'length($0)>72 {print FILENAME":"FNR}' src/*.cbl
```

#### Ausführen

```bash
make run          # baut und startet hello-world
make              # baut alles aus src/
make clean        # löscht bin/
```

Der Compiler-Aufruf dahinter:

```bash
cobc -x -Wall -fformat=fixed -o bin/hello-world src/hello-world.cbl
```

`-x` erzeugt ein ausführbares Binary. Ohne `-x` baut GnuCOBOL ein ladbares
Modul, das per `cobcrun` gestartet wird — das wird bei Unterprogrammen relevant.
GnuCOBOL übersetzt intern erst nach C und ruft dann clang auf; heraus kommt ein
normales natives Mac-Binary.

### Offener nächster Schritt

Vorschlag: Eingabe per `ACCEPT` einlesen und mit `PIC 9`-Feldern rechnen — dort
zeigt sich das dezimale Zahlenmodell, der größte Unterschied zu Java.
Alternativ direkt Richtung der geplanten minimalen Anwendung; dafür fehlt noch
die fachliche Festlegung, was sie tun soll.

---

## Session 2 — 2026-09-03 — Variablen, PICTURE-Klauseln, ACCEPT

### Auftrag

> Bitte lese das Verzeichnis ein und fahre als Cobol-Tutor fort

Damit: Roadmap-Punkt 2 — Variablen und `PIC`-Klauseln, Ein-/Ausgabe über
`ACCEPT`.

### Was gemacht wurde

`src/pic-basics.cbl` angelegt: liest Name und Kontostand vom Terminal und zeigt,
wie die Werte tatsächlich im Speicher liegen. Build warnungsfrei mit `-Wall`.

### Der Code

```cobol
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
```

### Ausgabe

Eingabe `Dominik` / `1234.50`:

```
Name    : Balance :
name  raw    [Dominik             ]
money raw    [01234.50]
money edited [ 1,234.50]
record raw   [Dominik             0123450]
```

### Erklärung

#### Gruppenfeld statt flacher Variablen

```cobol
       01  WS-CUSTOMER.
           05  WS-NAME            PIC X(20).
           05  WS-BALANCE         PIC 9(5)V99.
```

Ein `01`-Level ohne `PIC`-Klausel, darunter `05`-Level mit `PIC` — das ist ein
*Gruppenfeld*. Java-Gegenstück: ein Record/POJO mit zwei Feldern. Der
Unterschied: in Java ist ein Objekt eine Menge von Referenzen, in COBOL ist
`WS-CUSTOMER` schlicht ein **zusammenhängender Speicherbereich von 27 Bytes**
(20 + 7), und die `05`-Felder sind benannte Ausschnitte daraus. Deshalb geht
`DISPLAY WS-CUSTOMER` und liefert beide Felder aneinandergeklebt.

Die Level-Nummern sind reine Verschachtelungstiefe, keine Reihenfolge. In
Zehnerschritten (`01`, `05`, `10`) zu nummerieren ist Konvention, damit man
später eine Ebene dazwischenschieben kann.

#### Der gedachte Dezimalpunkt

Der zentrale Punkt der Session, direkt an der Ausgabe ablesbar:

```
money raw    [01234.50]      <- DISPLAY des Einzelfeldes
record raw   [Dominik             0123450]   <- die echten Bytes
```

`PIC 9(5)V99` belegt **7 Bytes** — fünf Ziffern, zwei Nachkommastellen. Das `V`
belegt kein Byte. Es ist ein reiner Compiler-Vermerk: „ab hier zählt es als
Nachkommastelle". Im Speicher steht `0123450`. Dass `DISPLAY` beim Einzelfeld
freundlich einen Punkt einfügt, ist Kosmetik von GnuCOBOL; die Gruppen-Ausgabe
zeigt die Wahrheit.

Genau das macht COBOL dezimal-exakt: es gibt keine Mantisse und keinen Exponenten,
sondern Ziffern und eine feste, zur Compile-Zeit bekannte Skalierung. Das
Java-Gegenstück ist `new BigDecimal(unscaled, 2)` — nicht `double`.

#### Editierte Felder

```cobol
       01  WS-BALANCE-EDITED      PIC ZZ,ZZ9.99.
```

Ein *edited field* ist ein reines Ausgabeformat. Die Zeichen der PICTURE sind
Anweisungen an den `MOVE`:

- `Z` — Ziffernstelle, führende Null wird zu Leerzeichen
- `9` — Ziffernstelle, Null bleibt Null (deshalb steht bei Betrag 0 dort `0.00`)
- `,` und `.` — werden real ins Feld geschrieben, als Zeichen

`MOVE WS-BALANCE TO WS-BALANCE-EDITED` formatiert also `01234.50` zu
` 1,234.50`. Mit einem editierten Feld darf man **nicht rechnen** — es ist ein
Text. In Java entspricht das `DecimalFormat` / `NumberFormat`, sauber getrennt
vom `BigDecimal`, das den Wert hält.

#### `ACCEPT` ist kein Parser

`ACCEPT WS-NAME` liest eine Zeile von STDIN. Bei `PIC X(20)` wird sie
linksbündig eingesetzt und rechts mit Leerzeichen aufgefüllt — sichtbar an
`[Dominik             ]`.

Bei numerischen Feldern wird es interessant. Gemessenes Verhalten von GnuCOBOL
3.2 mit `PIC 9(5)V99` (7 Ziffernstellen):

| Eingabe       | Ergebnis   | warum                                        |
| ------------- | ---------- | -------------------------------------------- |
| `1234.50`     | `01234.50` | passt genau                                   |
| `7.5`         | `00007.50` | rechts aufgefüllt                             |
| `12.345`      | `00012.34` | dritte Nachkommastelle abgeschnitten          |
| `99999.99`    | `99999.90` | nach 7 Zeichen ist Schluss: `99999.9`         |
| `123456.78`   | `23456.00` | 7 Zeichen `123456.`, dann führende Ziffer weg |
| `abc`         | `00000.00` | keine Ziffern, also null                      |

Die Regel dahinter: `ACCEPT` übernimmt höchstens so viele **Zeichen**, wie das
Feld **Ziffernstellen** hat (hier 7), und wandelt erst danach. Zu viele
Vorkommastellen werden **links** abgeschnitten, zu viele Nachkommastellen
rechts.

Und das Entscheidende: **kein Fehler, keine Exception, kein Rückgabewert.** Aus
`123456.78` wird stillschweigend `23456.00`. In Java wirft `new
BigDecimal("abc")` eine `NumberFormatException`; COBOL liefert 0 und macht
weiter. Eingabevalidierung ist in COBOL Handarbeit — Thema für einen späteren
Schritt (`IF ... NUMERIC`, `ON SIZE ERROR`).

#### `PERFORM` und die Punkte

```cobol
       MAIN-PARAGRAPH.
           PERFORM READ-CUSTOMER
           PERFORM SHOW-CUSTOMER
           STOP RUN.
```

`PERFORM <paragraph>` ist der Methodenaufruf: Sprung in den Paragraph, am Ende
automatisch zurück. Kein Stack, keine Parameter, kein Rückgabewert —
Kommunikation läuft ausschließlich über WORKING-STORAGE, also über Zustand.
Das ist beim Übersetzen nach Java die eigentliche Arbeit: aus impliziter
Zustandskopplung werden Parameter und Rückgabewerte.

Zu den Punkten: nur die **letzte** Anweisung jedes Paragraphen trägt einen. Ein
Punkt beendet den Satz — und ein Paragraph endet spätestens beim nächsten
Paragraph-Namen.

#### `WITH NO ADVANCING`

`DISPLAY 'Name    : ' WITH NO ADVANCING` unterdrückt den Zeilenumbruch, damit
die Eingabe hinter dem Prompt steht. Ohne den Zusatz ist `DISPLAY` immer ein
`println`.

### Offener nächster Schritt

Roadmap-Punkt 3: Rechnen mit `COMPUTE`, `ADD`, `MULTIPLY` — inklusive
`ROUNDED` und `ON SIZE ERROR`, dem COBOL-Gegenstück zu `RoundingMode` und dem
Überlauf, der oben stillschweigend passiert ist.

---

## Session 3 — 2026-09-03 — Hintergrund: Herkunft, GUI, Nebenläufigkeit

### Auftrag

> Eine Frage: lassen sich auch grafische Anwendungen mit COBOL bauen oder
> beschränkt sich das rein auf die Console? Etwas Hintergrundwissen zu COBOL
> wäre gut, wozu gibt es COBOL, für welchen Einsatzzweck ist es von wem
> entworfen worden? Was ist mit Konzepten wie Multi-Threading, wenn man das mal
> mit Java-Threads vergleichen würde? Außerdem: Der Vergleich mit Java [...] ist
> gut, solche Vergleiche soll es permanent/vermehrt geben.

Der letzte Punkt ist als Arbeitsregel in `CLAUDE.md` übernommen.

### Was gemacht wurde

Ein Beispielprogramm als Beleg zu den Fragen:

- `src/screen-demo.cbl` — `SCREEN SECTION`, eine Vollbild-Maske (GnuCOBOL
  bildet das auf ncurses ab). Muss in einem echten Terminal laufen.

### 1. Wozu gibt es COBOL, und von wem

**COBOL = COmmon Business-Oriented Language**, spezifiziert ab 1959 vom
CODASYL-Komitee (*Conference on Data Systems Languages*), einberufen auf
Initiative des **US-Verteidigungsministeriums**. Erste Spezifikation: COBOL 60.

Das Problem, das gelöst werden sollte: das DoD betrieb Rechner verschiedener
Hersteller, und jedes Verwaltungsprogramm musste für jede Maschine neu
geschrieben werden. Gesucht war eine **herstellerunabhängige Sprache für
kaufmännische Datenverarbeitung**. Das „Common" im Namen ist nicht Beiwerk, es
war das Killer-Feature.

**Grace Hopper** gilt als geistige Mutter: ihre Sprache FLOW-MATIC war die
maßgebliche Vorlage, sie war technische Beraterin des Komitees. Die eigentliche
Spezifikationsarbeit machte ein Kurzfrist-Komitee mit Leuten wie Jean Sammet
und Bob Bemer.

Java-Vergleich zum Motiv:

| Motiv                   | COBOL 1959                          | Java 1995                    |
| ----------------------- | ----------------------------------- | ---------------------------- |
| Ziel                    | ein Programm für alle Hersteller    | „write once, run anywhere"   |
| Lösungsweg              | ein *Standard*, pro Maschine ein Compiler | eine *VM* auf jeder Maschine |
| Wer trieb es            | US-Verteidigungsministerium         | Sun Microsystems             |
| Preis der Portabilität  | Compiler-Dialekte driften auseinander | VM muss überall portiert sein |

**Der Einsatzzweck** war von Anfang an eng gefasst: Massendatenverarbeitung in
der Verwaltung. Lohnabrechnung, Buchungsläufe, Versicherungspolicen,
Kontoauszüge, Bestandsführung. Das Muster ist immer dasselbe — Datensatz lesen,
transformieren, Datensatz schreiben, millionenfach. **Nicht** vorgesehen:
Systemprogrammierung, Numerik, Algorithmenforschung, Grafik.

Daraus folgt fast das ganze Sprachdesign:

| Design-Entscheidung                     | Weil                                             | Java-Gegenstück                        |
| --------------------------------------- | ------------------------------------------------ | -------------------------------------- |
| englischnahe Sätze (`MOVE A TO B.`)     | auch Fachabteilung und Revision sollen mitlesen  | keins — Java ist symbolisch (`b = a;`) |
| Daten strikt getrennt in `DATA DIVISION`| Satzformate sind das Zentrale, nicht die Logik   | ansatzweise: Records/DTOs, aber optional |
| Dezimalarithmetik eingebaut             | es geht um Geld, nicht um Physik                 | `BigDecimal` als Bibliothek, nicht Sprache |
| Dateien als Sprachkonstrukt (`SELECT`, `FD`) | Batch heißt: Datei rein, Datei raus          | `java.io`/NIO als Bibliothek           |
| feste Feldlängen, alles vorab allokiert | Speicher musste zur Compile-Zeit feststehen      | keins — GC und dynamische Objekte      |
| keine Rekursion (bis 2002)              | kein Stack-Bedarf, planbare Laufzeit             | Rekursion selbstverständlich           |

**Standards** (relevant, weil Legacy-Code sein Baujahr verrät): ANSI 68, 74, 85
(bringt strukturierte Programmierung: `END-IF`, `EVALUATE`, Scope-Terminatoren),
ISO 2002 (Objektorientierung, freies Format, `LOCAL-STORAGE`, Rekursion),
2014, 2023. Ein `GO TO`-lastiges Programm ohne `END-IF` ist typischerweise vor
1985 entstanden — oder von jemandem, der so gelernt hat.

### 2. Grafische Anwendungen

Kurzantwort: **nein, Console ist nicht die Grenze — aber eine GUI im Sinne von
Swing/JavaFX ist nicht Teil der Sprache.** Vier Ebenen:

**a) `SCREEN SECTION` — im Standard.** Eine fünfte Section in der
`DATA DIVISION`, die Bildschirmmasken deklarativ beschreibt: Position, Farbe,
Attribut, und welches WORKING-STORAGE-Feld dahinterliegt. `DISPLAY` zeichnet die
Maske, `ACCEPT` liest das ganze Formular auf einmal. Als Herstellererweiterung
entstanden, mit COBOL 2002 in den Standard gewandert. GnuCOBOL setzt es auf
ncurses um — siehe `src/screen-demo.cbl`.

```cobol
       SCREEN SECTION.
       01  SC-CUSTOMER-FORM.
           05  BLANK SCREEN.
           05  LINE 2 COL 5 VALUE 'CUSTOMER MAINTENANCE'
               FOREGROUND-COLOR 7 BACKGROUND-COLOR 4.
           05  LINE 4 COL 5 VALUE 'Name    :'.
           05  LINE 4 COL 15 PIC X(20) USING WS-NAME
               REVERSE-VIDEO AUTO.
```

Bemerkenswert daran: das ist **deklaratives UI mit Datenbindung** — Feld der
Maske und Feld im Speicher sind über `USING` gekoppelt, in beide Richtungen. Das
Konzept, für das Java Jahrzehnte später JavaFX-Properties oder JSF brauchte,
steckt hier in einer Section von 1970er-Jahre-Erweiterungen.

**b) Die Mainframe-Realität: CICS/BMS.** Auf dem 3270-Terminal beschreibt man
die Maske nicht im COBOL, sondern in einer separaten BMS-Map (bei IMS: MFS). Das
COBOL-Programm füllt nur eine generierte Struktur und sagt `EXEC CICS SEND MAP`.
Java-Vergleich: **das ist exakt Controller + Template.** Die Map ist das
JSP/Thymeleaf, das COBOL-Programm der Servlet-Controller, `SEND MAP` das
`render()`. Und wie beim Web ist die Interaktion request/response — die Maske
geht raus, das Programm endet, mit dem Absenden startet eine neue Transaktion.
Zustandslos, weil der Zustand in der Datenbank steht.

**c) Echte GUIs — herstellerspezifisch.** Kein Standard, aber es existiert:
Micro Focus *Visual COBOL* kompiliert COBOL nach **JVM-Bytecode** und .NET, dort
kann COBOL-Code Java- und Swing-Klassen direkt aufrufen; *isCOBOL* (Veryant)
läuft auf der JVM mit Swing-Bindings; Fujitsu *NetCOBOL* für .NET/WinForms;
*ACUCOBOL-GT* hat einen eigenen Fenster-Werkzeugkasten. Dazu kommt seit COBOL
2002 richtige **Objektorientierung** — `CLASS-ID`, `METHOD-ID`, Vererbung,
Interfaces. GnuCOBOL 3.2 unterstützt diesen Teil nicht:

```
error: 'CLASS-ID' is a reserved word, but isn't supported
```

**d) Heute üblich: COBOL als Backend.** Die Kernlogik bleibt COBOL, davor sitzt
eine Web- oder Mobile-UI, angebunden über REST-Fassaden (z.B. z/OS Connect),
MQ-Nachrichten oder — im schlimmsten Fall — Screen Scraping der 3270-Maske.

| Aufgabe               | COBOL                                  | Java                          |
| --------------------- | -------------------------------------- | ----------------------------- |
| Zeilenausgabe         | `DISPLAY`                              | `System.out.println`          |
| Vollbild-Terminal-UI  | `SCREEN SECTION` (Standard)            | Lanterna/JLine (Bibliothek)   |
| klassische Business-UI| CICS/BMS-Maps                          | Servlet + Template            |
| Desktop-GUI           | nur herstellerspezifisch               | Swing/JavaFX (Standard-JDK)   |
| Web-UI                | separate Schicht davor                 | nativ im Ökosystem            |

### 3. Multi-Threading

**Standard-COBOL kennt keine Threads.** Nicht „umständlich", sondern: es gibt
kein Sprachkonstrukt dafür. Kein Thread-Objekt, kein `synchronized`, keine
Monitore, keine `volatile`-Semantik — und, entscheidend, **kein
Speichermodell**. Java hat mit JSR-133 eine formale Spezifikation, was ein
Thread von den Schreibvorgängen eines anderen sehen darf. In COBOL existiert
diese Frage im Standard nicht.

Nebenläufigkeit gibt es trotzdem massiv — aber eine Ebene höher:

| Ebene                | Wie es in COBOL läuft                                          | Java-Gegenstück                     |
| -------------------- | -------------------------------------------------------------- | ----------------------------------- |
| viele Nutzer         | TP-Monitor (CICS, IMS/DC) startet dasselbe Programm als tausende Tasks | Servlet-Container, Thread pro Request |
| Batch-Parallelität   | JCL startet *n* Jobs über partitionierte Schlüsselbereiche     | `ExecutorService`, Parallel Streams |
| Isolation            | Adressraum bzw. Task des TP-Monitors                           | Thread-Stack + `ThreadLocal`        |
| gemeinsamer Zustand  | Datenbank mit Locks, `EXEC CICS ENQ/DEQ`                       | `synchronized`, `java.util.concurrent` |

Das Muster: **Nebenläufigkeit wird vom Container besorgt, nicht vom Programm.**
Der COBOL-Entwickler schreibt einzelthread-artigen Code, und die Umgebung führt
ihn vielfach parallel aus. Das ist derselbe Deal wie bei einem Servlet — nur
dass ein Servlet-Container tatsächlich Threads *in einem* Prozess benutzt und
deshalb Thread-Sicherheit vom Code verlangt.

#### Der eigentliche Knackpunkt: Wiedereintrittsfähigkeit

`WORKING-STORAGE` wird **einmal pro Programm** angelegt und behält seinen Wert
über alle Aufrufe hinweg. Das ist wörtlich ein `static`-Feld in Java. Wird so
ein Programm in einer Umgebung mit echten Threads mehrfach parallel ausgeführt,
teilen sich alle Ausführungen dieselben Variablen — eine Race Condition, die im
Quelltext unsichtbar ist, weil kein einziges Sprachkonstrukt auf Nebenläufigkeit
hindeutet.

```
WORKING-STORAGE = 01    LOCAL-STORAGE = 01
WORKING-STORAGE = 02    LOCAL-STORAGE = 01
WORKING-STORAGE = 03    LOCAL-STORAGE = 01
```

| COBOL                       | Lebensdauer                | Java                          |
| --------------------------- | -------------------------- | ----------------------------- |
| `WORKING-STORAGE SECTION`   | ganze Programmlaufzeit     | `static` Feld                 |
| `LOCAL-STORAGE SECTION`     | ein Aufruf                 | lokale Variable / Stack-Frame |
| `LINKAGE SECTION`           | verweist auf Aufrufer-Daten| Parameter, aber `by reference` |

Nebenbei: `RECURSIVE` in der `PROGRAM-ID` ist Pflicht, damit sich das Programm
überhaupt selbst aufrufen darf — bis COBOL 2002 war Rekursion verboten. Und
`GOBACK` statt `STOP RUN`, weil `STOP RUN` den ganzen Prozess beendet und die
äußeren Aufrufe mitnimmt; `GOBACK` ist das `return`.

Auf der IBM-Seite gibt es dazu die Compile-Option `THREAD` und in CICS das
Attribut *threadsafe*: historisch liefen alle Tasks kooperativ auf einem
einzigen TCB (dem Quasi-Reentrant-TCB), sodass echte Parallelität gar nicht
auftrat. Wer heute auf offene TCBs umstellt, bekommt echte Threads — und damit
schlagen genau die Programme fehl, die stillschweigend auf ihren
WORKING-STORAGE als Gedächtnis gebaut haben.

#### Konsequenz für die Migration nach Java

Zwei Fallen, beide direkt aus dem Obigen:

1. **`WORKING-STORAGE` → `static` ist die naive und falsche Übersetzung.** Sie
   ist semantisch korrekt für ein Einzelprogramm und eine Katastrophe, sobald
   der Java-Dienst mehrere Requests parallel bedient. Richtig ist meist:
   Instanzfelder eines Objekts, das pro Aufruf entsteht.
2. **Parallelisierung ist ein Architekturwechsel, keine Übersetzung.** Ein
   COBOL-Batch skaliert durch Partitionieren der Eingabedatei auf *n* Jobs. Die
   Java-Entsprechung wären Threads in einem Prozess mit gemeinsamem Heap — ein
   anderes Fehlermodell, andere Locks, anderes Wiederaufsetzen nach Abbruch.
   Der Batch-Restart, in COBOL/JCL ein gelöstes Problem, ist in Java plötzlich
   wieder eines (deshalb existiert Spring Batch).

### Offener nächster Schritt

Unverändert Roadmap-Punkt 3: `COMPUTE`, `ADD`, `ROUNDED`, `ON SIZE ERROR`.

---

## Session 4 — 2026-09-03 — `MOVE` ist Konvertierung, nicht Zuweisung

### Auftrag

> Kann man das `MOVE WS-BALANCE TO WS-BALANCE-EDITED` als eine Art Formatierung
> ansehen?

### Erklärung

**Ja — im Ergebnis ist es Formatierung.** Aber der Mechanismus ist ein anderer
als in Java, und der Unterschied ist wichtig.

`MOVE` ist keine Zuweisung. Es ist eine **typgesteuerte Konvertierung, deren
Regeln von der PICTURE des Zielfeldes kommen.** Editieren ist nur der
sichtbarste Fall davon: identische Anweisung, anderes Ziel, völlig anderes
Verhalten — auffüllen, abschneiden, formatieren, in Text wandeln.

Die Regeln aus der Ausgabe:

| Ziel          | Ergebnis     | Regel                                            |
| ------------- | ------------ | ------------------------------------------------ |
| `9(7)V99`     | `0001234.50` | am **Dezimalpunkt** ausgerichtet, links aufgefüllt |
| `9(2)V9`      | `34.5`       | am Dezimalpunkt ausgerichtet, beidseitig gekappt |
| `X(10)`       | `00042     ` | keine Ausrichtung, linksbündig, rechts Leerzeichen |
| `ZZ,ZZ9.99`   | ` 1,234.50`  | Editieren: führende Nullen zu Blanks             |
| `$$$,$$9.99`  | ` $1,234.50` | floating insertion: `$` rückt an die Zahl heran  |
| `---9.99`     | `  -12.34`   | floating sign, bei positivem Wert ein Blank      |

Zwei Dinge fallen auf. Erstens ist `9(2)V9` **stille Datenvernichtung**: aus
1234.50 wird 34.5, links *und* rechts abgeschnitten, ohne Warnung. Zweitens
funktioniert die Rückrichtung: `MOVE WS-ED-ZERO TO WS-DE-EDITED` liefert wieder
`01234.50`. Das heißt *de-editing* — der Compiler kennt das Editierformat und
kann es rückwärts lesen.

Und `MOVE WS-AMOUNT TO WS-TEXT` (also `9(5)V99` nach `X(10)`) wird zur
**Compile-Zeit abgelehnt**:

```
error: invalid MOVE statement
```

Ein Feld mit `V` hat keine textuelle Form, die der Compiler raten würde. Nur
ganzzahlige numerische Felder dürfen nach alphanumerisch. `MOVE` ist also
typgeprüft — es gibt eine echte Konvertierungsmatrix im Standard.

#### Gegenüberstellung mit Java

| Aspekt              | COBOL `MOVE ... TO`                     | Java                                        |
| ------------------- | --------------------------------------- | ------------------------------------------- |
| Was es ist          | Anweisung, schreibt in vorhandenes Feld | Ausdruck, erzeugt neues `String`-Objekt     |
| Wo das Format steht | an der **Deklaration des Ziels**        | am **Aufrufort**: `String.format("%,.2f",x)` |
| Nächster Verwandter | Feld, das seine Darstellung kennt (`@JsonFormat`, `@NumberFormat`) | `DecimalFormat`-Instanz                     |
| Rückrichtung        | de-editing, dieselbe Anweisung          | `DecimalFormat.parse()`, andere Methode      |
| Typprüfung          | Compile-Zeit, Konvertierungsmatrix      | `String.format` nimmt fast alles zur Laufzeit |
| Überlauf            | still gekappt                           | `BigDecimal.setScale` wirft `ArithmeticException` |
| Speicher            | Ziel ist Teil eines Satzes, feste Breite | String liegt frei auf dem Heap              |

Der konzeptionelle Kern: In Java ist Formatierung eine **Funktion über einen
Wert**. In COBOL ist sie eine **Eigenschaft des Zielspeichers**. Deshalb ist
`WS-BALANCE-EDITED` auch kein `String` — es ist ein eigener Datentyp
(*numeric-edited*), mit dem man nicht rechnen darf, der aber genug Struktur
behält, um zurückkonvertiert zu werden.

Für die Migration heißt das: ein editiertes Feld wird in Java **nicht** zu einem
Feld. Es wird zu einer Formatierung an der Ausgabestelle. Wer es als
`String`-Feld ins POJO übernimmt, schleppt eine Darstellung durch die
Geschäftslogik.

Nachtrag zur Vollständigkeit: bei **Gruppenfeldern** kippt das Verhalten. Ein
`MOVE` von Gruppe zu Gruppe ist ein reiner Byte-Kopiervorgang ohne jede
Konvertierung — die Zielstruktur wird ignoriert. Wenn die Layouts nicht exakt
gleich sind, entsteht Datensalat, den kein Compiler bemängelt.

### Offener nächster Schritt

Weiterhin Roadmap-Punkt 3: `COMPUTE`, `ADD`, `ROUNDED`, `ON SIZE ERROR`.

---
