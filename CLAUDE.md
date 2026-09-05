# CLAUDE.md

## Projektziel

Lernprojekt: COBOL-Grundlagen erarbeiten, eine minimale Anwendung schreiben und
diese anschließend nach Java konvertieren. Der Nutzer (Dominik) lernt COBOL neu,
Java ist bekannt.

## Arbeitsweise (wichtig)

- **Erst Code schreiben, dann erklären.** Nicht vorab Theorie ausbreiten —
  lauffähigen Code liefern und im Anschluss Zeile für Zeile erläutern.
- **Konversation auf Deutsch, Code und Kommentare auf Englisch.**
- **Jeder Schritt muss lokal auf macOS lauffähig sein.** Nach jeder Änderung
  `make run` ausführen und das echte Programmausgabe zeigen.
- Klein anfangen, ein Konzept pro Schritt.
- **Java-Vergleiche permanent mitliefern.** Jedes COBOL-Konzept gegen sein
  Java-Gegenstück stellen (wie im Abschnitt "COBOL ist in DIVISIONs gegliedert"
  in `docs/konversation.md`) — auch dort, wo es *kein* Gegenstück gibt, denn
  gerade das ist lehrreich. Java ist die bekannte Sprache, also der Ankerpunkt.
- **Jede Session am Ende in `docs/konversation.md` protokollieren:** neuen
  Abschnitt `## Session N — YYYY-MM-DD — <Thema>` unten anfügen, mit dem Auftrag
  des Nutzers (wörtlich), was gemacht wurde, dem Code und der Erklärung. Das Log
  ist das Lernarchiv des Projekts und soll ohne den Chat-Verlauf lesbar sein.
- **Hilfsprogramme gehören nach `src/helper/`, fortlaufend nummeriert.** Jedes
  Programm, das Claude schreibt, um ein Konzept zu demonstrieren, kommt nach
  `src/helper/` und heißt `NN-<thema>.cbl` (`01-pic-basics.cbl`,
  `02-screen-demo.cbl`, …). Die Nummer gibt die didaktische Reihenfolge wieder,
  nicht zwingend die zeitliche — beim Anlegen die nächste freie Nummer vergeben
  und bestehende in Ruhe lassen; umsortiert wird nur auf Ansage des Nutzers.
  Die `PROGRAM-ID` bleibt **ohne** Nummer (`PIC-BASICS`, nicht
  `01-PIC-BASICS`) — die Nummer ordnet Dateien, sie gehört nicht zum
  Programm. Das ist die einzige Ausnahme von der Regel "`PROGRAM-ID` gleich
  dem Dateinamen".
- **`src/` gehört dem Nutzer.** Dort liegen ausschließlich seine eigenen
  Programme (`hello-world.cbl`, `prog0.cbl`), unnummeriert. Nie eine Datei
  direkt in `src/` anlegen oder eine seiner Dateien dort verändern, ohne dass
  er es ausdrücklich verlangt. `make run MAIN=<name>` findet Programme in
  beiden Ordnern, die Binaries landen weiterhin flach in `bin/`.
- **`docs/key-facts.md` gehört dem Nutzer.** Dort stehen ausschließlich seine
  eigenen Notizen in seinen eigenen Worten. Nichts eigenmächtig ergänzen,
  umformulieren, korrigieren oder sortieren — nur auf ausdrückliche Ansage
  anfassen, und dann seinen Wortlaut übernehmen. Fachliche Korrekturen oder
  Vertiefungen gehören in die Antwort im Chat, nicht in diese Datei.

## Git

**Commits und Pushes macht der Nutzer selbst.** Niemals `git commit`, `git push`,
`git tag` oder ähnliche schreibende Git-Operationen ausführen — auch nicht
"hilfsweise" am Ende einer Aufgabe. Lesende Befehle (`git status`, `git diff`,
`git log`) sind in Ordnung.

## Toolchain

- Compiler: **GnuCOBOL 3.2.0**, installiert über Homebrew (`brew install gnucobol`)
- Binary: `/opt/homebrew/bin/cobc` (ggf. `export PATH="/opt/homebrew/bin:$PATH"`)
- Java-Zielseite kommt später dazu (noch kein Build-Setup vorhanden)

## Build & Run

```bash
make                 # alle Programme aus src/ und src/helper/ bauen
make run             # Standardprogramm (hello-world) bauen und starten
make run MAIN=name   # <name>.cbl aus src/ oder src/helper/ starten
make clean           # bin/ löschen
```

Direkt ohne Make:

```bash
cobc -x -Wall -fformat=fixed -o bin/hello-world src/hello-world.cbl
./bin/hello-world
```

## Projektstruktur

```
src/         COBOL-Quellen des Nutzers (*.cbl), ein Programm pro Datei
src/helper/  Demo-Programme von Claude, nummeriert (NN-<thema>.cbl)
bin/         Kompilierte Binaries, flach aus beiden Quellordnern (gitignored)
docs/        konversation.md — fortlaufendes Protokoll der Tutor-Sessions
             key-facts.md   — Notizen des Nutzers (nur von ihm gepflegt)
```

## COBOL-Konventionen in diesem Projekt

- **Fixed-Format** (nicht free-format), weil das der Realität in
  Legacy-Codebasen entspricht, die man nach Java migriert:
  - Spalten 1–6: Sequenznummern (bleiben leer)
  - Spalte 7: Indikator (`*` = Kommentar, `-` = Fortsetzung)
  - Spalten 8–11: Area A — DIVISION, SECTION, Paragraph-Namen, Level `01`/`77`
  - Spalten 12–72: Area B — alle Statements
  - **Nie über Spalte 72 hinaus schreiben**, sonst wird stillschweigend
    abgeschnitten. Prüfen mit:
    `awk 'length($0)>72 {print FILENAME":"FNR}' src/*.cbl src/helper/*.cbl`
- Schlüsselwörter und Bezeichner in GROSSBUCHSTABEN, Wortteile mit `-` getrennt.
- Präfixe für Datenfelder: `WS-` für WORKING-STORAGE, `LS-` für LOCAL-STORAGE,
  `LK-` für LINKAGE SECTION.
- `PROGRAM-ID` gleich dem Dateinamen (in Großbuchstaben), bei nummerierten
  Helfern ohne das `NN-`-Präfix.
- Builds müssen **warnungsfrei** sein (`-Wall`). Obsolete Klauseln wie `AUTHOR.`
  daher nicht verwenden.

## Blick nach vorn: Konvertierung nach Java

Beim Schreiben von COBOL-Code darauf achten, dass die Struktur später sauber
abbildbar bleibt:

| COBOL                         | Java-Gegenstück                       |
| ----------------------------- | ------------------------------------- |
| `PROGRAM-ID`                  | Klasse                                |
| `WORKING-STORAGE SECTION`     | Felder der Klasse (statisch/langlebig)|
| `01`-Gruppe mit `05`-Feldern  | POJO / Record                         |
| Paragraph + `PERFORM`         | Methode + Aufruf                      |
| `PIC 9(n)V9(m)` (dezimal)     | `BigDecimal`, **nicht** `double`      |
| `PIC X(n)`                    | `String` fester Länge (rechts gepaddet)|
| `CALL 'SUBPROG' USING ...`    | Methoden-/Klassenaufruf               |

Der Punkt mit `BigDecimal` ist zentral: COBOL rechnet dezimal-exakt. Wer das in
Java mit `double` nachbaut, produziert Rundungsfehler in Geldbeträgen.
