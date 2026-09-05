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

`src/helper/01-pic-basics.cbl` angelegt: liest Name und Kontostand vom Terminal und zeigt,
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

- `src/helper/02-screen-demo.cbl` — `SCREEN SECTION`, eine Vollbild-Maske (GnuCOBOL
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
ncurses um — siehe `src/helper/02-screen-demo.cbl`.

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

## Session 5 — 2026-09-05 — Rechnen mit dezimalen Feldern

### Auftrag

> Fahre mit Punkt 3 der Roadmap fort

Roadmap-Punkt 3: *Rechnen mit dezimalen Feldern (`COMPUTE`, `ADD`)*.

### Was gemacht wurde

Neues Programm `src/helper/04-arithmetic.cbl`. Es zeigt vier Dinge an einem
Rechnungsbeispiel: `COMPUTE` gegen die Verb-Formen, Abschneiden gegen
`ROUNDED`, `ON SIZE ERROR` gegen stillen Überlauf, und `DIVIDE ... REMAINDER`.

### Code

```cobol
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
           ...

      * A result too large for the target: guarded and unguarded.
       SHOW-SIZE-ERROR.
           COMPUTE WS-SMALL = WS-NET
               ON SIZE ERROR
                   DISPLAY 'guarded    result rejected, field unchanged'
           END-COMPUTE
           ...

      * Classic money split: the remainder must not disappear.
       SHOW-SHARES.
           DIVIDE WS-TOTAL BY WS-PARTS GIVING WS-SHARE
               REMAINDER WS-REST
           ...
```

(Vollständige Quelle in `src/helper/04-arithmetic.cbl`; hier sind nur die
DISPLAY-Blöcke gekürzt.)

### Ausgabe

```
$ make run MAIN=04-arithmetic
cobc -x -Wall -fformat=fixed -o bin/04-arithmetic src/helper/04-arithmetic.cbl
./bin/04-arithmetic
--- invoice ---
net          1,234.56
rate       0.1900
vat            234.57   (rounded)
gross        1,469.13

--- 234.5664 into PIC 9(5)V9 ---
default        234.5     (truncated)
ROUNDED        234.6

--- 1234.56 into PIC 9(3)V99 ---
guarded    result rejected, field unchanged
value now        0.00
via MOVE       234.56   (silently cut)

--- 1000.00 split 3 ways ---
share          333.33
remainder        0.01
```

### Erklärung

#### `V` ist kein Zeichen

`WS-VAT-RATE PIC 9V9(4)` hat eine Vor- und vier Nachkommastellen. Das `V`
belegt keinen Speicher, es markiert nur die **gedachte** Kommaposition.
Gespeichert stehen fünf Ziffern `01900`. Der Compiler kennt die Position und
richtet bei jeder Rechnung danach aus — daher die dezimale Exaktheit.

#### `COMPUTE` gegen die Verb-Formen

```cobol
COMPUTE WS-VAT ROUNDED = WS-NET * WS-VAT-RATE
ADD WS-NET TO WS-VAT GIVING WS-GROSS
```

`COMPUTE` nimmt einen **Ausdruck** mit `+ - * / **` und Klammern — die Form,
die einer Java-Zeile am nächsten kommt. Die Verb-Formen (`ADD`, `SUBTRACT`,
`MULTIPLY`, `DIVIDE`) nehmen **Operanden**, keine Ausdrücke, und stammen aus
der Zeit, in der COBOL sich wie Englisch lesen sollte.

Die Falle sitzt in `TO` gegen `GIVING`:

| Form                  | Bedeutung                                  |
| --------------------- | ------------------------------------------ |
| `ADD A TO B`          | `B = B + A` — **B wird überschrieben**     |
| `ADD A TO B GIVING C` | `C = A + B` — B bleibt unberührt           |

Ohne `GIVING` ist der letzte Operand zugleich das Ziel. Bei `SUBTRACT` dreht
sich zusätzlich die Leserichtung: `SUBTRACT A FROM B` heißt `B = B - A`. Beim
Lesen von Legacy-Code ist das eine der häufigsten Fehlinterpretationen.

#### Abschneiden ist der Standard

Das exakte Produkt ist `234.5664`, das Zielfeld hat eine Nachkommastelle.
COBOL **schneidet ab**, sofern nicht `ROUNDED` dabeisteht — kein Rundungsfehler
wie bei `double`, sondern eine exakt definierte Kappung, aber eine stille.

Zwischenergebnisse sind davon nicht betroffen: in `COMPUTE X = A * B / C`
rechnet der Compiler intern mit voller Genauigkeit und kappt erst beim
Speichern ins Ziel.

#### `ON SIZE ERROR` ist die einzige Bremse

`1234.56` passt nicht in `PIC 9(3)V99`. Mit `ON SIZE ERROR` wird die Zuweisung
**verworfen** — das Feld behält seinen alten Wert (`0.00`) und der Fehlerzweig
läuft. Ohne Guard (oben über `MOVE` gezeigt) verschwinden die führenden
Ziffern kommentarlos: aus 1234.56 wird 234.56. Faktor 1000 an Schaden, ohne
Warnung, ohne Log.

`ON SIZE ERROR` fängt auch Division durch Null — eine Exception dafür gibt es
in COBOL nicht.

#### `DIVIDE ... REMAINDER`

1000,00 auf drei Teile: jeder 333,33, ein Cent bleibt liegen. COBOL liefert
den Rest in einem eigenen Feld, statt ihn zu verlieren. Genau diese Sorte
Genauigkeit ist der Grund, warum der Code in Banken nie abgelöst wurde.

#### Gegenüberstellung mit Java

| Aspekt                  | COBOL                                    | Java                                        |
| ----------------------- | ---------------------------------------- | ------------------------------------------- |
| Zahlentyp               | dezimal, feste Skala aus `PIC`           | `BigDecimal` mit `scale` — **nie** `double` |
| Rechnen                 | `COMPUTE X = A * B`                      | `x = a.multiply(b)` — kein Operator-Overloading |
| Skala des Ergebnisses   | an der **Deklaration des Ziels**         | am **Aufrufort**: `.setScale(2, …)`         |
| Standardverhalten       | abschneiden, stillschweigend             | `ArithmeticException`, wenn `scale` nicht passt |
| Runden                  | `ROUNDED` (half-up)                      | `RoundingMode.HALF_UP` explizit             |
| Überlauf                | still gekappt, außer mit `ON SIZE ERROR` | `BigDecimal` wächst; Overflow gibt es nicht |
| Division durch Null     | `ON SIZE ERROR`                          | `ArithmeticException`                       |
| Rest                    | `DIVIDE … REMAINDER R`                   | `a.divideAndRemainder(b)` → `BigDecimal[2]` |
| `ADD A TO B`            | mutiert `B`                              | kein Gegenstück — `BigDecimal` ist immutable |

Der letzte Punkt tut bei einer Migration weh. `BigDecimal` ist
**unveränderlich**: jede Operation liefert ein neues Objekt. COBOL-Felder sind
**Speicherplätze fester Breite**, die überschrieben werden. Ein Paragraph mit
`ADD WS-AMOUNT TO WS-TOTAL` in einer Schleife wird in Java zu
`total = total.add(amount)` — die Zuweisung muss man hinschreiben, sonst
passiert nichts.

Und die Skala: in COBOL steht sie einmal in der WORKING-STORAGE SECTION und
gilt für jede Zuweisung an dieses Feld. In Java muss man sie an **jeder**
Rechenstelle wiederholen. Wer das vergisst, bekommt entweder eine
`ArithmeticException` oder eine Genauigkeit, die von der Eingabe abhängt statt
vom Feld. Der übliche Ausweg bei Migrationen ist eine kleine Wrapper-Klasse pro
Feldtyp, die `scale` und `RoundingMode` kapselt — sie ersetzt genau das, was
`PIC 9(5)V99` von sich aus mitbringt.

### Offener nächster Schritt

Roadmap-Punkt 4: Kontrollfluss — `IF`, `EVALUATE`, `PERFORM ... UNTIL`.

---

## Session 6 — 2026-09-05 — Vorzeichenbehaftete Zahlen: `S9` und `S9V9`

### Auftrag des Nutzers

> Gebe mir zwei Datentypen für Ganze Zahlen (auch negative) und Dezimalzahlen
> (auch negative) aus

### Die zwei Typen

```cobol
       01  WS-INT            PIC S9(5)        VALUE -12345.
       01  WS-DEC            PIC S9(5)V9(2)   VALUE -12345.67.
```

- `S9(5)` — ganze Zahl, 5 Stellen: −99999 … +99999
- `S9(5)V9(2)` — Dezimalzahl, 5 vor / 2 nach dem Komma

`S` steht für *signed*. Ohne `S` ist das Feld vorzeichenlos, und ein negativer
Wert kommt beim `MOVE` als Betrag an — stillschweigend.

### Erklärung

**Das `S` kostet kein Byte.** `S9(5)` belegt genauso 5 Bytes wie `9(5)`. Das
Vorzeichen wird in die letzte Ziffer hineingerechnet — *overpunch*, Erbe der
Lochkarte. Liest man dieselben Bytes über `REDEFINES ... PIC X(5)`, steht dort
`1234u`: Ziffer und Minus sind ein einziges Zeichen geworden. Deshalb darf man
COBOL-Dateien in Java nicht mit `new String(bytes, US_ASCII)` einlesen.

`SIGN LEADING SEPARATE` schaltet das ab — ein Byte mehr, dafür ein echtes `-`
vorne im Puffer. So sieht man es in Schnittstellendateien.

**Ausgabe braucht ein *edited field*.**

```cobol
       01  WS-DEC-PRETTY     PIC ---,--9.99.
```

Das `-` schwimmt bis vor die erste signifikante Ziffer; `-12345.67` wird zu
`-12,345.67`. Ein edited field ist kein Rechentyp — `COMPUTE` darauf ist
verboten. Man rechnet in `S9(5)V9(2)` und `MOVE`-t erst am Schluss.

### Gegenüberstellung mit Java

| Aspekt              | COBOL                  | Java                          |
| ------------------- | ---------------------- | ----------------------------- |
| Ganzzahl signed     | `PIC S9(5)`            | `int` / `long`                |
| Dezimal signed      | `PIC S9(5)V9(2)`       | `BigDecimal`, `scale = 2`     |
| Vorzeichenlos       | `PIC 9(5)`             | **kein Gegenstück**           |
| Zeichen-Speicherung | overpunch letzte Ziffer| Zweierkomplement              |
| Wertebereich        | über **Stellenzahl**   | über **Bitbreite**            |
| Ausgabeformat       | eigener Feldtyp        | `DecimalFormat` am Aufrufort  |
| Vorzeichenverlust   | still bei `MOVE`       | Compilerfehler                |

Zwei Punkte für die Migration:

**Java hat kein `PIC 9(5)`.** `int` ist immer signed. Ein Feld ohne `S` sagt
fachlich „hier kann nichts negativ werden" — diese Zusicherung steht im COBOL
in der Datendeklaration und geht bei der Konvertierung verloren. Sie muss als
Validierung nachgebaut werden.

**Das Format gehört in COBOL zum Feld, in Java zum Aufrufort.**
`PIC ---,--9.99` ist ein deklarierter Typ, jedes `MOVE` formatiert automatisch.
In Java wiederholt man `new DecimalFormat("#,##0.00")` an jeder Ausgabestelle —
dasselbe Muster wie `scale` in Session 5, derselbe Ausweg: eine Wrapper-Klasse
pro fachlichem Feldtyp.

---

## Session 7 — 2026-09-05 — Truncation: welche Ziffer überlebt?

### Auftrag des Nutzers

> Schaue dir das Programm prog1 an. Dort rechne ich unten
> `COMPUTE VAR5 = VAR0 - VAR3`, also 5-99 = 94. Die Ausgabe ist 4. Die 9 wird
> warum nicht ausgegeben? VAR5 hat eine Ziffer, ich hätte jetzt erwartet das
> von der 94 die 9 ausgegeben wird und nicht die 4.

### Ausgangslage

`src/prog1.cbl`, unverändert:

```cobol
       01  VAR0                   PIC S9(5) VALUE 5.
       01  VAR3                   PIC S9(2) VALUE 99.
       01  VAR5                   PIC 9(1).
           COMPUTE VAR5 = VAR0 - VAR3
```

Ausgabe: `4`. Die Rechnung ergibt −94, nicht 94.

### Erklärung

Es passieren **zwei** Dinge hintereinander: `VAR5` ist ohne `S` deklariert,
also fällt das Minus weg (−94 → 94), und `VAR5` hat nur eine Stelle, also
werden die **hohen** Ziffern abgeschnitten (94 → 4).

**Die Regel:** Numerische Felder werden am **Dezimalpunkt** ausgerichtet, nicht
am linken Rand. `PIC 9(1)` heißt nicht „die erste Ziffer", sondern genau die
**Einerstelle**. −94 hat dort die 4; die Zehnerstelle existiert im Ziel nicht.

Dasselbe Fenster kappt bei Bedarf beide Enden: `S9(3)V9(2)` mit `123.45` in ein
`S9(1)V9(1)` gibt `3.4` — links 12 verloren, rechts die 5.

**Der Kontrast:** `PIC X` richtet **links** aus. `X(5)` → `X(2)` behält `AB`.
Text hat keinen Dezimalpunkt, also gilt dort die umgekehrte Regel — genau die,
die man beim Zahlenfall erwartet hätte.

**Warum kein Fehler kommt:** COBOL schneidet still ab. Das ist Voreinstellung,
kein Versehen — in einer Batch-Verarbeitung mit Millionen Sätzen wollte man
1960 keinen Abbruch wegen eines Überlaufs. Die Prüfung muss man anfordern:

```cobol
           COMPUTE VAR5 = VAR0 - VAR3
               ON SIZE ERROR MOVE 'yes' TO WS-FLAG
           END-COMPUTE
```

Dabei wird das Ziel **gar nicht** beschrieben: es behält seinen alten Wert.
Dort steht also nicht der abgeschnittene Wert, sondern der vorherige.

### Gegenüberstellung mit Java

| Fall                      | COBOL                       | Java                              |
| ------------------------- | --------------------------- | --------------------------------- |
| Zahl passt nicht ins Ziel | still gekappt, hohe Ziffern | `(byte) 300` = 44, hohe Bits weg  |
| Überlaufprüfung           | `ON SIZE ERROR` (optional)  | `Math.addExact()` wirft           |
| Zu viele Nachkommastellen | still abgeschnitten         | `setScale(n)` → Exception         |
| Text zu lang              | rechts gekappt, kein Fehler | `substring` nötig                 |
| Vorzeichen an `9(n)`      | still verloren              | Compilerfehler / nicht möglich    |

Der `(byte)`-Cast trifft es am besten: `(byte) 300` ergibt 44, weil die hohen
**Bits** wegfallen. COBOL macht dasselbe mit den hohen **Ziffern**, nur dezimal
— `94 mod 10 = 4`. Beides ist still, aber in Java steht wenigstens ein
sichtbarer Cast im Ausdruck. In COBOL steht der „Cast" in der
Datendeklaration, hunderte Zeilen weiter oben.

Für die Migration: `COMPUTE VAR5 = A - B` naiv als `var5 = a.subtract(b)` zu
übersetzen ändert das Verhalten. Jedes COBOL-Zielfeld einer Berechnung ist
implizit ein Modulo plus Vorzeichenbehandlung.

### Offener nächster Schritt

Unverändert Roadmap-Punkt 4: Kontrollfluss — `IF`, `EVALUATE`,
`PERFORM ... UNTIL`.

---

## Session 8 — 2026-09-05 — Dateizugriff: CSV, Indexdateien, Embedded SQL

### Auftrag des Nutzers

> Wie funktioniert das mit der Datenbankanbindung in Cobol, angenommen ich
> möchte eine kleine Warehouse Verwaltung schreiben, wie würde man das machen?
> Kann man Datensätze in CSVs verwalten?

Nachgereicht:

> Bitte das auch in die Konversation mit aufnehmen. Wenn ich 06 indexed file
> mehrmals hintereinander ausführe, werden mir immer die gleichen Zahlen
> ausgegeben

### Was gemacht wurde

Zwei neue Helfer:

- `src/helper/05-csv-file.cbl` — flache Textdatei (`LINE SEQUENTIAL`),
  Zeile bauen mit `STRING`, zerlegen mit `UNSTRING`.
- `src/helper/06-indexed-file.cbl` — Indexdatei (`INDEXED`, ISAM) mit
  `RECORD KEY`, `READ ... KEY IS`, `REWRITE`, `START` / `READ NEXT`.

Neu ist der Ordner `data/`, in dem beide Programme ihre Dateien ablegen
(`items.csv`, `items.dat`). Beides ist Programm-Output, gehört also in
`.gitignore`. `items.dat` ist ein BDB-Binärformat, kein Text.

### Die drei Wege, wie COBOL an Daten kommt

| Weg              | COBOL                       | Realität                | Java                     |
| ---------------- | --------------------------- | ----------------------- | ------------------------ |
| Flache Textdatei | `ORGANIZATION LINE SEQUENTIAL` | Import/Export, Batch | `BufferedReader`         |
| Indexdatei       | `ORGANIZATION INDEXED`      | der Bestandsspeicher    | kein Gegenstück in der JDK |
| Echte DB         | `EXEC SQL ... END-EXEC`     | DB2, Oracle, PostgreSQL | JDBC, aber per Precompiler |

Kurzantwort auf die Frage: CSV geht, ist für eine Warehouse-Verwaltung aber
das falsche Werkzeug. CSV ist ein **Austauschformat**, der Bestand selbst
gehört in eine Indexdatei.

### 1. CSV — `05-csv-file.cbl`

Erzeugte Datei:

```
A-100,Hex bolt M8,120,0.35
A-101,Washer 8mm,4300,0.02
B-200,Gear wheel,17,89.90
```

Ausgabe des Programms:

```
written: data/items.csv

ID     NAME                   QTY      VALUE
-------------------------------------------
A-100  Hex bolt M8          120        42.00
A-101  Washer 8mm           4300       86.00
B-200  Gear wheel           17      1,528.30
-------------------------------------------
total stock value                1,656.30
```

**COBOL kennt kein CSV.** Keine Bibliothek, kein `split(",")`. Eine Zeile ist
`PIC X(80)`, zusammengebaut und zerlegt wird von Hand.

#### Die Datei anmelden

```cobol
           SELECT ITEM-FILE ASSIGN TO "data/items.csv"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS  IS WS-STATUS.
```

`ITEM-FILE` ist der interne Name, der Pfad steht draußen. Das gehört in die
ENVIRONMENT DIVISION, weil genau das der maschinenabhängige Teil ist. Auf dem
Mainframe steht hier kein Pfad, sondern ein DD-Name, den der JCL-Job zur
Laufzeit an einen echten Datensatz bindet — COBOLs Dependency Injection.

#### Der Record-Buffer

```cobol
       FD  ITEM-FILE.
       01  ITEM-RECORD            PIC X(80).
```

Der zentrale Unterschied zu Java: `ITEM-RECORD` ist *ein* Speicherbereich, den
jeder `READ` überschreibt. Kein Objekt pro Zeile, keine Allokation, kein GC.

> **Java:** `while ((line = br.readLine()) != null)` erzeugt pro Zeile ein
> neues `String`-Objekt. COBOL liest in denselben Puffer — deshalb läuft ein
> Batch mit 50 Mio. Sätzen in konstantem Speicher, und deshalb sind die Daten
> des letzten Satzes weg, sobald der nächste gelesen wird.

#### `FILE STATUS` statt Exceptions

COBOL wirft nicht. Nach jedem I/O stehen zwei Ziffern im Statusfeld:

| Code | Bedeutung                    |
| ---- | ---------------------------- |
| `00` | ok                           |
| `10` | Dateiende (`AT END`)         |
| `23` | Key nicht gefunden           |
| `35` | Datei existiert nicht        |

> **Java:** `IOException`. Der COBOL-Weg ist der C-Weg (`errno`): kein
> Stacktrace, keine Propagierung. Wer den Status nicht prüft, rechnet mit Müll
> weiter. Für die Migration wichtig: nach einem Fehler läuft COBOL *weiter* —
> ein naives `try/catch` ändert das Verhalten.

#### Zeile bauen — `STRING`

```cobol
           MOVE WS-QTY   TO WS-QTY-TEXT
           MOVE WS-PRICE TO WS-PRICE-TEXT
           STRING FUNCTION TRIM(WS-ID)         ","
                  FUNCTION TRIM(WS-NAME)       ","
                  FUNCTION TRIM(WS-QTY-TEXT)   ","
                  FUNCTION TRIM(WS-PRICE-TEXT)
               DELIMITED BY SIZE INTO ITEM-RECORD
           END-STRING
```

Der Umweg über `WS-PRICE-TEXT PIC Z(4)9.99` ist nötig: `PIC 9(5)V99` mit Wert
`0.35` steht im Speicher als `0000035`, denn `V` ist ein *gedachter*
Dezimalpunkt, kein Byte. Direkt gestringt stünde `0000035` in der Datei. Das
Edited-Field macht `    0.35` daraus, `TRIM` schneidet die Blanks weg.

> **Java:** `String.join(",", ...)`. `DELIMITED BY SIZE` heißt „jeden Operanden
> in voller Länge nehmen" — es ist *kein* Trennzeichen, die Kommas sind ganz
> normale Operanden der Liste.

#### Zeile zerlegen — `UNSTRING`

```cobol
           UNSTRING ITEM-RECORD DELIMITED BY ","
               INTO WS-IN-ID WS-IN-NAME WS-IN-QTY WS-IN-PRICE
           END-UNSTRING
           COMPUTE WS-LINE-VALUE ROUNDED =
               FUNCTION NUMVAL(WS-IN-QTY) * FUNCTION NUMVAL(WS-IN-PRICE)
```

`UNSTRING` ist `split(",")`, nur werden die Ziele einzeln hingeschrieben — es
gibt kein Array variabler Länge, vier deklarierte Felder heißt maximal vier
gelesene Felder. Die Zahlen kommen als **Text** zurück und müssen mit
`FUNCTION NUMVAL` in Numerik übersetzt werden.

> **Java:** `new BigDecimal(parts[3])`. `NUMVAL` entspricht genau `BigDecimal`,
> nicht `Double.parseDouble` — der Wert ist dezimal-exakt.

**Was CSV nicht kann:** einen Satz gezielt lesen (immer von vorne durch), einen
Satz ändern (`REWRITE` scheitert bei `LINE SEQUENTIAL`, weil eine andere
Zeilenlänge die Nachbarn überschreiben würde), gleichzeitige Zugriffe sichern.

### 2. Indexdatei — `06-indexed-file.cbl`

```cobol
           SELECT ITEM-FILE ASSIGN TO "data/items.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS DYNAMIC
               RECORD KEY   IS IT-ID
               FILE STATUS  IS WS-STATUS.

       FD  ITEM-FILE.
       01  ITEM-RECORD.
           05  IT-ID              PIC X(6).
           05  IT-NAME            PIC X(20).
           05  IT-QTY             PIC 9(5).
           05  IT-PRICE           PIC 9(5)V99.
```

Zwei Dinge sind anders als bei CSV. Erstens hat der Record **Struktur** —
keine 80 anonymen Bytes, sondern vier benannte Felder fester Position. Kein
`STRING`, kein `UNSTRING`, kein `NUMVAL` mehr im ganzen Programm. Zweitens
macht `RECORD KEY IS IT-ID` das Feld zum Primärschlüssel; die Laufzeit hält
dafür einen B-Tree.

> **Java:** Dafür gibt es in der Standardbibliothek **kein Gegenstück**. Am
> nächsten kommt eine persistente `TreeMap<String, Record>` — MapDB, Berkeley
> DB JE, oder pragmatisch SQLite. Hier hat COBOL als *Sprachbestandteil*, was
> Java als Framework nachrüsten muss.

#### Gezielt lesen und ändern

```cobol
           MOVE "A-101" TO IT-ID
           READ ITEM-FILE KEY IS IT-ID
               INVALID KEY DISPLAY "not found"
           END-READ

           ADD 500 TO IT-QTY
           REWRITE ITEM-RECORD
```

Key-Feld füllen, lesen, Puffer ändern, zurückschreiben.

> **Java:** `map.get("A-101")` und `map.put(...)`, oder in SQL `SELECT ...
> WHERE id = ?` plus `UPDATE`. `INVALID KEY` mit Status `23` ist das `null` aus
> `map.get()`. `ACCESS MODE DYNAMIC` heißt nur: gezielter *und* sequenzieller
> Zugriff im selben Programm.

#### Sortiert durchlaufen

```cobol
           MOVE LOW-VALUES TO IT-ID
           START ITEM-FILE KEY IS GREATER THAN IT-ID
           PERFORM UNTIL WS-EOF = "Y"
               READ ITEM-FILE NEXT RECORD
                   AT END     MOVE "Y" TO WS-EOF
                   NOT AT END PERFORM SHOW-ONE
               END-READ
           END-PERFORM
```

Geschrieben wurde in der Reihenfolge B-200, A-100, A-101 — zurück kommt es
sortiert:

```
ID     NAME                   QTY      VALUE
-------------------------------------------
A-100  Hex bolt M8           120      42.00
A-101  Washer 8mm           4800      96.00
B-200  Gear wheel             17   1,528.30
```

`START` positioniert den Cursor, `READ NEXT` läuft von dort weiter.

> **Java:** `map.tailMap(key).entrySet().iterator()`, oder ein JDBC-`ResultSet`
> mit `ORDER BY`. `START` / `READ NEXT` ist ein Cursor, exakt im DB-Sinn.

### 3. Echte Datenbank — Embedded SQL

Im Bestandscode die häufigste Variante:

```cobol
       WORKING-STORAGE SECTION.
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-ID       PIC X(6).
       01  HV-QTY      PIC S9(5) COMP-5.
           EXEC SQL END DECLARE SECTION END-EXEC.
           EXEC SQL INCLUDE SQLCA END-EXEC.

       PROCEDURE DIVISION.
           MOVE "A-101" TO HV-ID
           EXEC SQL
               SELECT QTY INTO :HV-QTY FROM ITEMS WHERE ID = :HV-ID
           END-EXEC
           IF SQLCODE NOT = 0 ...
```

`:HV-ID` sind **Host-Variablen**: normale COBOL-Felder, die im SQL auftauchen.
Ein Precompiler (DB2, oder `ocesql` gegen PostgreSQL) übersetzt die
`EXEC SQL`-Blöcke vor dem eigentlichen Compiler in `CALL`s.

> **Java:** JDBC mit `PreparedStatement`; `:HV-ID` ist das `?`. Der
> Unterschied: JDBC ist eine *Laufzeit*-API mit SQL als String, Embedded SQL
> wird **zur Compile-Zeit** geprüft und ans echte Schema gebunden. Ein
> Tippfehler im Spaltennamen fliegt beim Precompile auf, nicht im
> Produktivbetrieb. Preis: ein zusätzlicher Buildschritt. Statt
> `SQLException` gibt es wieder ein Statusfeld — `SQLCODE` in der `SQLCA`.

### Nachtrag: warum mehrfache Läufe dieselben Zahlen liefern

Beobachtung des Nutzers: `06-indexed-file` mehrmals gestartet, immer dasselbe
Ergebnis. Die Daten *wurden* gespeichert — sie wurden beim nächsten Start nur
sofort wieder gelöscht, von dieser Zeile:

```cobol
       LOAD-FILE.
           OPEN OUTPUT ITEM-FILE
```

`OPEN OUTPUT` heißt nicht „zum Schreiben öffnen", sondern **„neu anlegen"**.
Existiert die Datei, wird sie auf Länge null gesetzt. Jeder Lauf schrieb also
die drei Sätze frisch, setzte A-101 auf 4300 und buchte 500 dazu — 4800,
zwangsläufig immer.

Die vier OPEN-Modi:

| Modus    | Bedeutung                      | Datei muss existieren? | Java                              |
| -------- | ------------------------------ | ---------------------- | --------------------------------- |
| `INPUT`  | nur lesen                      | ja, sonst Status `35`  | `new FileInputStream(f)`          |
| `OUTPUT` | **neu anlegen, Inhalt weg**    | nein, wird erzeugt     | `new FileOutputStream(f)`         |
| `I-O`    | lesen *und* zurückschreiben    | ja, sonst Status `35`  | `RandomAccessFile(f, "rw")`       |
| `EXTEND` | hinten anhängen                | nein                   | `new FileOutputStream(f, true)`   |

> **Java:** Dieselbe Falle wie `new FileOutputStream(file)` gegenüber
> `new FileOutputStream(file, true)`, bzw. `TRUNCATE_EXISTING` gegenüber
> `APPEND`. Nur fehlt in Java wenigstens sichtbar ein Flag — in COBOL steht
> das harmlose Wort `OUTPUT` da und sieht nach nichts aus.

Der Fix: es gibt kein `OPEN OUTPUT IF NOT EXISTS`, also fragt man den Status.

```cobol
       ENSURE-FILE.
           OPEN INPUT ITEM-FILE
           IF WS-STATUS = "35"
               PERFORM LOAD-FILE
           ELSE
               CLOSE ITEM-FILE
               DISPLAY "data/items.dat exists -- keeping the stock"
           END-IF.
```

Der fehlgeschlagene `OPEN` ist hier kein Ausnahmefall, sondern die normale
Fallunterscheidung — genau dafür ist `FILE STATUS` da.

> **Java:** `if (!Files.exists(p)) seed(p);` als eigenständige Abfrage. COBOL
> hat das nicht: die Existenz erfährt man nur, indem man es versucht und den
> Status liest.

Drei Läufe hintereinander, jetzt kumulativ:

```
### Lauf 1 (Datei fehlt)
loaded 3 records into data/items.dat
lookup A-101 -> Washer 8mm, qty 04300
booked in 500 -> qty now 04800

### Lauf 2
data/items.dat exists -- keeping the stock
lookup A-101 -> Washer 8mm, qty 04800
booked in 500 -> qty now 05300

### Lauf 3
data/items.dat exists -- keeping the stock
lookup A-101 -> Washer 8mm, qty 05300
booked in 500 -> qty now 05800
```

### Empfehlung für die Warehouse-Verwaltung

`ORGANIZATION INDEXED`. Läuft ohne Zusatzsoftware (GnuCOBOL nutzt hier BDB,
sichtbar über `cobc --info`), bietet Key-Zugriff, Update in place und sortierte
Läufe — und entspricht dem, was in echtem Legacy-Code steht, wo statt BDB dann
VSAM darunter liegt. CSV bleibt daneben nützlich: Lieferantenliste einlesen,
Inventurbericht rausschreiben.

Für die spätere Java-Migration ist die Indexdatei der angenehmere Fall: sie
bildet sich sauber auf eine Tabelle mit Primary Key ab, jedes `05`-Feld wird
ein Record-Feld, `PIC 9(5)V99` wird `BigDecimal`. Ein `UNSTRING`-Parser
dagegen ist Logik, die Zeile für Zeile nachgebaut und getestet werden muss.

### Offener nächster Schritt

Weiterhin offen: Kontrollfluss — `IF`, `EVALUATE`, `PERFORM ... UNTIL`.
Angeboten, aber noch nicht beauftragt: eine kleine echte Warehouse-Anwendung
auf `INDEXED` mit Menü (Anlegen / Suchen / Einbuchen / Liste).

---
