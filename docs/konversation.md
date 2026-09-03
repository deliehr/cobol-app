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
