# cobol-app

Ein Lernprojekt: COBOL von Grund auf, in kleinen Schritten — mit dem Ziel, die
fertige Anwendung anschließend nach Java zu konvertieren.

Aktueller Stand: **Dezimale Arithmetik — `COMPUTE`, `ROUNDED`, `ON SIZE ERROR`.**

## Voraussetzungen

macOS mit [Homebrew](https://brew.sh) und GnuCOBOL:

```bash
brew install gnucobol
cobc --version   # erwartet: cobc (GnuCOBOL) 3.2.0 oder neuer
```

GnuCOBOL ist ein Open-Source-COBOL-Compiler. Er übersetzt COBOL nach C und ruft
dann den System-Compiler auf (auf dem Mac clang) — das Ergebnis ist ein normales
natives Binary.

## Bauen und starten

```bash
make run
```

Ausgabe:

```
Hello, World!
```

Weitere Targets:

| Befehl                 | Wirkung                                        |
| ---------------------- | ---------------------------------------------- |
| `make`                 | alle Programme aus `src/` und `src/helper/` bauen |
| `make run`             | `hello-world` bauen und ausführen              |
| `make run MAIN=<name>` | `<name>.cbl` aus beiden Ordnern bauen und starten |
| `make clean`           | `bin/` entfernen                               |

Ohne Make geht es genauso:

```bash
cobc -x -Wall -fformat=fixed -o bin/hello-world src/hello-world.cbl
./bin/hello-world
```

Kurzform:

```bash
cobc -x -Wall -fformat=fixed -o bin/hello-world src/hello-world.cbl;./bin/hello-world;
```

Die Flags bedeuten:

- `-x` — ein ausführbares Programm erzeugen (ohne `-x` entsteht ein Modul, das
  man mit `cobcrun` laden müsste)
- `-Wall` — alle Warnungen anzeigen
- `-fformat=fixed` — Quelltext im klassischen Fixed-Format lesen (Spaltenregeln,
  siehe unten)

## Projektstruktur

```
.
├── src/                 eigene COBOL-Quellen, ein Programm pro Datei
│   ├── hello-world.cbl
│   ├── prog0.cbl
│   └── helper/          Demo-Programme aus den Tutor-Sessions, in Lernreihenfolge
│       ├── 01-pic-basics.cbl
│       ├── 02-screen-demo.cbl   SCREEN SECTION (braucht ein echtes Terminal)
│       ├── 03-pic-scale.cbl
│       └── 04-arithmetic.cbl
├── bin/                 kompilierte Binaries (nicht versioniert)
├── docs/
│   ├── konversation.md  Protokoll der Lern-Sessions (Code + Erklärungen)
│   └── key-facts.md     eigene Notizen zu den Kernkonzepten
├── Makefile
├── CLAUDE.md            Projektkontext und Konventionen für Claude Code
└── README.md
```

## Das Fixed-Format-Layout

Dieses Projekt nutzt bewusst das klassische Fixed-Format, weil realer
Legacy-COBOL-Code so aussieht. Jede Zeile ist in Spaltenbereiche eingeteilt:

```
Spalte:  1----6 7 8---11 12----------------------------------72 73----80
         │      │ │      │                                     │
         Seq.   │ Area A Area B                                ignoriert
                Indikator
```

- **1–6** Sequenznummern, historisch die Lochkartennummer — bleiben heute leer
- **7** Indikatorspalte: `*` macht die Zeile zum Kommentar, `-` setzt ein
  Literal der Vorzeile fort
- **8–11** *Area A*: `DIVISION`- und `SECTION`-Köpfe, Paragraph-Namen und
  Datenfelder der Stufe `01`
- **12–72** *Area B*: alle Anweisungen
- **73–80** wird vom Compiler ignoriert

Wichtigste Fallgrube: **alles ab Spalte 73 verschwindet stillschweigend.**
Prüfen lässt sich das so:

```bash
awk 'length($0)>72 {print FILENAME":"FNR}' src/*.cbl src/helper/*.cbl
```

## Roadmap

- [x] Hello World — Grundstruktur der vier DIVISIONs
- [x] Variablen und `PIC`-Klauseln, Ein-/Ausgabe über `ACCEPT`
- [x] Rechnen mit dezimalen Feldern (`COMPUTE`, `ADD`)
- [ ] Kontrollfluss: `IF`, `EVALUATE`, `PERFORM ... UNTIL`
- [ ] Datenstrukturen: Gruppenfelder und Tabellen (`OCCURS`)
- [ ] Dateiverarbeitung: sequenzielle Datei lesen und verarbeiten
- [ ] Unterprogramme (`CALL ... USING`)
- [ ] Konvertierung der Anwendung nach Java
