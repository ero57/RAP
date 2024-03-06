# RISCV-Prozessor in VHDL

## Über das Projekt

Dieses Repository dokumentiert die Entwicklung eines RISCV-Prozessors im Rahmen eines Informatik-Studiums. Ziel des Projekts war es, einen funktionalen und effizienten RISCV-Prozessor mit VHDL zu entwickeln. Das Projekt ist in 10 Termine gegliedert, mit spezifischen Zielen und Aufgabenstellungen für jeden Termin.

### Termin 01 - ALU und Einführung in RISC-V
Ziel dieses Termins war das Verständnis der Prozessorspezifikation von RISC-V und die Entwicklung einer ALU (Arithmetic Logic Unit) für den Prozessor. Eine wichtige Referenz war das Handbuch "The RISC-V Instruction Set Manual". Die Aufgaben umfassten:

- Einführung in die Grundlagen von RISC-V.
- Entwicklung einer ALU in VHDL, die verschiedene arithmetische und logische Operationen unterstützt.
- Erstellung einer Testbench für die ALU, um ihre Funktionalität zu überprüfen.

Die ALU sollte dabei verschiedene Operationen wie Addition, Shift-Operationen und Vergleiche unterstützen. Die Herausforderung bestand darin, die Spezifikationen korrekt zu interpretieren und eine funktionierende ALU sowie eine entsprechende Testbench zu implementieren.

---

### Termin 02 - Register und Pipeline

In diesem Abschnitt des Projekts lag der Schwerpunkt auf dem Verständnis der Unterscheidung zwischen Rechenwerk und Steuerwerk in Prozessoren und der Implementierung von Registern und Pipelines.

#### Rechenwerk vs. Steuerwerk
Die Aufgabe bestand darin, die frühere Trennung von Prozessoren in Rechenwerk und Steuerwerk zu verstehen. Während das Rechenwerk das Programm ausführte, las und interpretierte das Steuerwerk die Befehle und steuerte das Rechenwerk entsprechend an.

#### Pipeline
Ein wichtiger Aspekt war das Prinzip der Pipeline in Prozessoren, das für eine effizientere Befehlsbearbeitung sorgt, indem mehrere Befehle gleichzeitig in verschiedenen Stufen der Pipeline bearbeitet werden. Die Pipeline-Stufen wurden in 'Instruction Fetch', 'Instruction Decode', 'Operand Fetch', 'Execute', 'Memory Access' und 'Store (result)' unterteilt.

#### Aufgaben und Implementierung
1. **Entity für die Register X0 bis X31 des Prozessors**: Implementierung von 32 indizierbaren Registern, um sie in VHDL als Array zu strukturieren, sodass auf sie mit einer fünfstelligen Binärzahl zugegriffen werden kann.

2. **Testbench für die Register**: Überprüfung von Lese- und Schreibzugriffen, um sicherzustellen, dass die geschriebenen Werte korrekt gelesen werden können und dass das Register X0 unverändert bei 0 bleibt.

3. **Generisches Pipeline-Register erstellen**: Implementierung eines generischen D-Registers, das auf der fallenden Flanke Daten von den Eingängen zu den Ausgängen überträgt.

4. **Testbench für das generische Pipeline-Register**: Überprüfung der Spezifikation des Registers, insbesondere um sicherzustellen, dass unterschiedliche Registerbreiten korrekt funktionieren.

---

### Termin 03 - Komplettes Rechenwerk

In dieser Phase des Projekts wurde das gesamte Rechenwerk des RISCV-Prozessors entwickelt, das drei Haupt-Pipelinestufen umfasst: "Operand Fetch" ("OP/F"), "Execute" und "Store Result" ("Store").

#### Aufbau des Rechenwerks
- Die "Execute"-Stufe enthält die ALU und ein zusätzliches Addierwerk für Sprungziele.
- "Operand Fetch" beinhaltet drei Multiplexer, die Daten aus den Registern oder früheren Pipelinestufen an die "Execute"-Stufe weiterleiten.
- Die "Store Result"-Stufe dient der Entkopplung der "Execute"-Stufe von der Aufgabe, das Ergebnis in das Zielregister zu schreiben.

#### Hauptaufgaben
1. **Verstehen des Rechenwerks**: Durchspielen eines ADD-Befehls (z.B. "add x1,x2,x3") und Verständnis der erforderlichen Steuersignale und der Pipeline-Arbeit.
2. **Rechenwerk in VHDL erstellen**: Entwicklung des Rechenwerks in VHDL basierend auf einer definierten Entity, einschließlich der Implementierung der ALU, des Registersatzes und einer Reihe von Pipeline-Registern.
3. **Erstellen einer einfachen Testbench**: Erstellung einer Testbench, die alle Datenpfade zumindest einmal verwendet, um sicherzustellen, dass sich keine trivialen Fehler eingeschlichen haben. Detailliertere Tests erfolgen, sobald die "Instruction Decode"-Stufe hinzukommt.

#### Wichtige Hinweise
- Eine genaue Überprüfung und das Verständnis des Datenflusses im Rechenwerk sind für die korrekte Implementierung unerlässlich.
- Die Debug-Ausgaben (debug_rd und debug_addr_of_rd) sind für Testzwecke wichtig und ermöglichen die Kontrolle der Rechenergebnisse.

---

### Termin 04 - Instruction Decode

In dieser Phase des Projekts wurde die "Instruction Decode"-Stufe des RISCV-Prozessors entwickelt, die für die Ansteuerung des Rechenwerks basierend auf Maschinenbefehlen zuständig ist.

#### Wichtige Aspekte der Instruction Decode-Stufe
- Empfangen der Maschinenbefehle vom "Instruction Register" (IR), das von der noch zu implementierenden "Instruction Fetch"-Stufe pro Takt gespeist wird.
- Umwandlung der Binärkodierung der Befehle in Steuersignale für das Rechenwerk.
- Alle Ausgaben der "Instruction Decode"-Stufe müssen durch eine Pipeline-Register-Schicht geleitet werden, die mit dem Signal cpuclk getaktet wird.

#### Hauptaufgaben
1. **Ausfüllen der Tabelle mit Steuersignalen**: Ausarbeitung der erforderlichen Steuersignale für das Rechenwerk basierend auf den Maschinenbefehlen und unter Berücksichtigung der Spezifikationen aus dem Handbuch der RISC-V-Architektur.
2. **Erstellung der "Instruction Decode"-Stufe**: Entwicklung dieser Pipeline-Stufe in VHDL, einschließlich der Generierung von Signalen wie pc, lit, jumplit, addr_of_rs1, addr_of_rs2, addr_of_rd, aluop, sel_pc_not_rs1, sel_lit_not_rs2 und is_jalr.
3. **Erstellung einer Testbench für "Instruction Decode"**: Entwicklung einer Testbench, die für jede Zeile der erstellten Tabelle einen Testfall enthält, um die korrekte Funktionalität der "Instruction Decode"-Stufe zu gewährleisten.

#### Implementierungshinweise
- Setzen von sinnvollen Default-Werten zu Beginn, um den Implementierungsaufwand zu reduzieren.
- Ein sorgfältiger Entwurf und Test der "Instruction Decode"-Stufe ist entscheidend, da sie eine Schlüsselrolle bei der Ansteuerung des Rechenwerks spielt.

---

### Termin 05 - Instruction Fetch

In dieser Phase des Projekts wurde die "Instruction Fetch" (I/F)-Stufe des RISCV-Prozessors entwickelt. Diese Stufe ist verantwortlich für das Laden von Befehlen in die Pipeline.

#### Aufgaben der "Instruction Fetch"-Stufe
- Nutzung des "Program Counter" (PC) zur Adressierung des Speichers und Weitergabe der ausgelesenen Befehle (32 Bit) an die nachfolgende Stufe im "Instruction Register" (IR).
- Parallel dazu wird im Register PCout gespeichert, unter welcher Adresse das Befehlswort gefunden wurde.
- Bei Ankündigung eines Sprungziels durch das Signal "do_jump" wird der PC mit dem Wert von "jumpdest" geladen.

#### Meilensteine und Herausforderungen
- Aufgrund der Unvollständigkeit des Prozessors wurde ein ROM mit einem festen Programm in der I/F-Stufe implementiert, um erste Programme laufen zu lassen, bevor der richtige Speicher implementiert wird.
- Zur Behebung von Daten-Hazards wurde ein Mechanismus eingeführt, der nach jedem Maschinenbefehl sieben NOPs (No Operation) einfügt.

#### Hauptaufgaben
1. **Erstellen der "Instruction Fetch" Pipelinestufe**: Entwicklung einer Pipelinestufe, die das Laden von Befehlen und die entsprechende PC-Verwaltung übernimmt.
2. **Erstellung einer Testbench für "Instruction Fetch"**: Überprüfung, ob die ersten drei Befehlswörter mit dem zugehörigen Wert vom PC erscheinen, einschließlich der sieben NOPs zwischen den Befehlen.
3. **Implementierung von Milestone 1**: Zusammenführen der bisher erstellten Entities und Überprüfung der Funktionsweise des zusammengesetzten Prozessors.
4. **Behebung eines Fehlers in Termin 2**: Anpassung des d_reg, sodass es initial den Wert 0 erhält, um Probleme in der Simulation zu vermeiden.
5. **Erstellung einer Testbench für Milestone 1**: Überprüfung, ob die erwarteten Ergebnisse in der richtigen Reihenfolge erscheinen.

---

### Termin 06 - Pipeline Hazards und Interlocking

In dieser Phase wurde behandelt, wie man Hazards in einem Prozessor behebt, insbesondere im Kontext des RISCV-Projektprozessors.

#### Daten-Hazards
- **Problem**: Daten-Hazards treten auf, wenn ein Befehl einen veralteten Wert liest, obwohl das Rechenergebnis bereits am Ausgang der ALU existiert.
- **Lösung**: Einführung von "Operand Forwarding" durch Zurückführen des Rechenergebnisses der ALU zur Operand-Fetch-Stufe und Ansteuerung eines neuen Multiplexers.
- **Ansteuerung des Multiplexers**: Ein Vergleicher prüft, ob die Adresse des Zielregisters (addr_of_rd) mit der Adresse des zweiten Operanden (addr_of_rs2) übereinstimmt und schaltet bei Gleichheit auf das ALU-Ergebnis.

#### Jump-Hazards
- **Problem**: Jump-Hazards entstehen, wenn ein Sprungbefehl erkannt wird, aber bereits drei Befehle in der Pipeline sind, die nicht ausgeführt werden sollten.
- **Lösung**: Annulierung der Befehle durch Umwandlung in NOPs, die fehlerhaft in die Pipeline gelangt sind.

#### Hauptaufgaben
1. **Modifizieren des Rechenwerks**: Um Daten-Hazards zu verhindern, wurde eine Kopie des Rechenwerks angelegt und entsprechend modifiziert, um "Operand Forwarding" zu ermöglichen.
2. **Anpassen der Testbench für das Rechenwerk**: Ergänzung der Testbench, um zu überprüfen, ob Daten-Hazards korrekt aufgelöst werden.
3. **Einführung von "annul"-Signalen**: Erweiterung der instruction_decode-Stufe um ein "annul"-Signal, um Befehle in der Pipelinestufe zu NOPs umzuwandeln und so den Systemzustand nicht mehr zu verändern.

#### Zusätzliche Überlegungen
- Berücksichtigung von Sonderfällen, wie dem Verhalten, wenn die Adresse des zweiten Operanden "00000" ist.
- Implementierung von Gattern hinter den Ausgängen der D-Register, um bestimmte Werte zu erzwingen.

---

### Termin 07 - Cache

In dieser Phase des Projekts wurde ein Cache-System für den RISCV-Prozessor implementiert, um die Geschwindigkeitseinbußen aufgrund des langsameren Hauptspeichers zu kompensieren.

#### Einführung in Caching
- Caches sind kleinere Speicher, die schneller als der Hauptspeicher sind und dazu dienen, häufig genutzte Daten für den Prozessor schneller verfügbar zu machen.
- Ein sogenannter "Single-Associative-Cache" wurde für diesen Prozessor implementiert.

#### Single-Associative Cache
- Der Cache speichert einen kleineren Teil des Hauptspeichers und wählt Daten aus, die vermutlich wieder benötigt werden, basierend auf dem Lokalitätsprinzip.
- Bei einem Cache-Miss (wenn die Daten nicht im Cache vorhanden sind), werden die benötigten Daten vom Hauptspeicher geholt und in den Cache geladen.

#### Hauptaufgaben
1. **Erstellen der Cache Entity**: Entwicklung einer Entity, die den Cache und seine Interaktionen mit dem Prozessor und dem Hauptspeicher steuert.
2. **Erstellen einer Testbench**: Testen des Caches, insbesondere, ob beim ersten Zugriff auf einen Wert ein Cache-Miss auftritt und beim zweiten Zugriff der Wert aus dem Cache geladen wird.
3. **Modifizieren der Instruction-Fetch-Stufe**: Anpassung der Instruction-Fetch-Stufe, um den Speicherzugriff durch den Cache zu integrieren.
4. **Modifikation von Milestone 1**: Integration des Instruction-Caches in das Gesamtsystem und Test der Funktionsweise.
5. **Testen des Caches am Prozessor**: Überprüfung, ob der Prozessor effizient auf die Instruktionen zugreift und der Cache korrekt funktioniert.

#### Zusätzliche Überlegungen
- Die Implementierung eines Caches ist ein wesentlicher Schritt zur Effizienzsteigerung des Prozessors und kann die Geschwindigkeit des Gesamtsystems erheblich beeinflussen.
- Während der Implementierung wurden sowohl die Theorie als auch die praktischen Aspekte des Caching berücksichtigt, um ein grundlegendes Verständnis für die Funktionsweise von Cache-Systemen zu schaffen.

---

### Termin 08 - Assembler

In dieser Phase des Projekts erfolgte der Übergang vom Hardware-Design zur Assemblerprogrammierung. Dieser Schritt markiert den Wechsel von der Erstellung eines Prozessors zur Anwendung desselben.

#### Kernaspekte
- **Einführung in die Assemblerprogrammierung**: Vermittlung grundlegender Kenntnisse und Fähigkeiten in der Assemblerprogrammierung.
- **Speicheranbindung und Peripherie**: Diskussion über Speicheranbindung, Ein- und Ausgabeeinheiten sowie die Notwendigkeit von ROM für den Bootprozess und RAM für den Hauptspeicher.
- **Erstellung eines "Hello, World"-Programms in Assembler**: Als erstes praktisches Beispiel wurde ein einfaches Assemblerprogramm erstellt, das "Hello, World" ausgibt.

#### Übungen und Aufgaben
- **Verwendung des Ripes-Simulators**: Einführung in den Gebrauch des Ripes Assembler/Simulators für RISC-V Architektur.
- **Registerkonventionen bei RISC-V**: Erläuterung der Registerkonventionen, um eine standardisierte Nutzung der CPU-Register zu gewährleisten.
- **Einfache Addition in Assembler**: Ausführung einer einfachen Additionsaufgabe in Assembler, um das Grundverständnis zu festigen.
- **Entwicklung eines Taschenrechner-Programms**: Programmierung eines einfachen Taschenrechners in Assembler, der Addition und Subtraktion von Zahlen ermöglicht.

#### Wichtige Konzepte
- **Relokation und Labels**: Erläuterung der Bedeutung von Relokation und der Verwendung von Labels in Assembler-Programmen.
- **RISC-V Befehle, Macros, Direktiven und Systemaufrufe**: Unterscheidung zwischen verschiedenen Arten von Assembler-Befehlen und ihre Anwendungen.

---

### Termin 09 - Praktische Anwendung von Assembler

Dieser Teil des Projekts konzentrierte sich auf die praktische Anwendung der Assemblerprogrammierung, insbesondere unter Beachtung der Registerkonventionen.

#### Hauptziele und Aufgaben
- **Vertiefung der Registerkonventionen**: Praktische Übungen zur Anwendung und Vertiefung des Wissens über Registerkonventionen in der Assemblerprogrammierung.
- **Entwicklung spezifischer Algorithmen in Assembler**: Jede Aufgabe erfordert die Implementierung eines vorgegebenen Algorithmus unter Einhaltung der Registerkonventionen und der Präsentation von Ergebnissen auf dem Bildschirm.

#### Spezifische Übungen
1. **Fakultät, iterativ**: Implementierung eines iterativen Algorithmus zur Berechnung der Fakultät einer Zahl.
2. **Fibonacci, rekursiv**: Entwicklung eines rekursiven Programms zur Berechnung der Fibonacci-Folge.
3. **Sieb des Eratosthenes**: Programmierung des Siebs des Eratosthenes zur Identifizierung von Primzahlen.
4. **Caesar-Kodierung**: Erstellung eines Programms zur Caesar-Kodierung und -Dekodierung von Texten.

#### Zusätzliche Hinweise
- **Implementierungsmethodik**: Für bestimmte Aufgaben wie das Sieb des Eratosthenes wurde vorgeschlagen, Arrays im Stack anzulegen und spezielle Register für Basisadressen zu verwenden.
- **Anwendungsbereiche**: Diese Übungen bieten praktische Einblicke in die Anwendung von Assemblerprogrammierung für verschiedene mathematische und kryptografische Operationen.

---

### Termin 10 - Compiler Templates

In diesem Abschnitt des Projekts lag der Schwerpunkt auf dem Verständnis der Codeerzeugung durch Compiler und der praktischen Umsetzung dieses Wissens in Assembler-Programme.

#### Hauptthemen
- **Verständnis von Compiler Templates**: Erläuterung der Prozesse, durch die Compiler Quellcode in Maschinensprache umwandeln, insbesondere die Bedeutung der Baumstruktur bei der Übersetzung.
- **Praktische Anwendung von Compiler Templates**: Die Studierenden sollten Compiler Templates in Assembler-Programme umsetzen.

#### Praktische Übungen
1. **Implementierung von Compiler-Templates für IF-Statements**: Erstellung eines Templates für "IF"-Konstrukte und deren Umsetzung in Assembler.
2. **Euklidischer Algorithmus**: Schreiben eines Assembler-Programms für den euklidischen Algorithmus zur Berechnung des größten gemeinsamen Teilers zweier Zahlen.
3. **Compiler-Template für Arrays**: Erarbeitung eines Templates für die Behandlung von Array-Zugriffen in Assembler.
4. **Taschenrechner 2**: Erweiterung des Taschenrechners aus Termin 9 um zusätzliche Funktionen und vorzeichenbehaftete Zahlen.
5. **Ballon-Findung**: Implementierung eines Programms, das bestimmt, wie oft ein gegebener String aus einem Zeichenvorrat gebildet werden kann.

#### Zusätzliche Lerninhalte
- **Baumstruktur für Codeerzeugung**: Verständnis, wie ein Quellcode zuerst in eine Baumstruktur konvertiert wird, um die Codeerzeugung zu erleichtern.
- **Registerverwaltung**: Einblick in die Registerverwaltung durch Compiler und die Optimierung der Registerzuweisung.

---
