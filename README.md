# Energi-workshop

En liten workshop for å se på energiforbruk i koden og hva som påvirker den.

## Eksempelkode

Utgangspunktet er [One Billion Row Challenge](1brc.dev). Dette er et enkelt lite problem som går
ut på å kjappest mulig lese en fil med 1 milliard temperaturmålinger og skrive ut målestasjonene i alfabetisk rekkefølge og med minimums-, gjennomsnitts- og maksimumstemperatur for hver.

Koden fra utfordringen ligger i katalogen 1brc/java. Denne koden er lisensiert med Apache 2.0 lisensen. Se avsnitt om 'Java-kode' for mer info om opphavsrett til denne koden.

# Oppgaver

## Oppgave 1

Det første som trengs er å lage en fil med målinger som kan leses. Dette gjøres ved å bygge 1brc/java med Java 21 og Maven 3.9. Deretter kjøres den resulterende jar-filen med et antall rader som skal genereres som parameter.

Det enkleste er å kjøre skriptet 'c' i 1brc:
```shell
./c 100
```

Hvis bash ikke er tilgjengelig, kjøres genereringen via standard Java-kommandoer:
```shell
mvn package
java -cp target/average-1.0.0-SNAPSHOT.jar dev.morling.onebrc.CreateMeasurements 100
```

Den resulterende filen 'measures.txt' inneholder så 100 rader og kan benyttes i de påfølgende oppgavene. Det kan være lurt å lage litt forskjellige varianter med litt forskjellig antall rader. Å kjøre baseline-koden med 100 millioner rader tar over 20 sekunder på min maskin.

## Oppgave 2

Det finnes en enkel Java-implementasjon i mappen 'java'. Denne leser alle linjene i filen, splitter hver linje på ; og lager en instans av Measurement-klassen for hver linje. Så bruker den en Collector til å gruppere på målestasjonsnavn og aggregere opp min, maks og gjennomsnitt i en MeasurementAggregator. Til slutt lagres resultatet i en ResultRow der resultatet sorteres vha. en TreeMap for så å bli skrevet ut derfra. 70 linjer og ikke noe fancy.

Denne må bygges og kjøres:
```shell
mvn package
java -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution ../1brc/measurements.txt
# Kan også ta tiden ved å bruke 'time'-kommandoen:
time java -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution ../1brc/measurements.txt
```

Prøv gjerne med litt forskjellige filer.

## Oppgave 3

[JoularJX](https://www.noureddine.org/research/joular/joularjx) er en Java-agent som måler energiforbruket til en applikasjon under kjøring.
Versjon 3.0.0 er vedlagt i repoet. Agenten bruker Intel sitt RAPL (Running Average Power Limit) grensesnitt for å lese av energibruken til
applikasjonen under kjøring. Siden dette går inn i kjernen av prosessoren, er dette kun tilgjengelig via priviligert tilgang. Det betyr at vi må laste ned og installere drivere og verktøy fra GitHub og kjøre de i administratormodus. Her er det mange røde flagg!

### Virtuell maskin?

Å kjøre det i en virtuell maskin, fungerer ganske dårlig, ettersom det faktiske energiforbruket må hentes fra en faktisk prosessor. Det er mulig å installere noe som f.x. [PowerJoular](https://www.noureddine.org/articles/powerjoular-1-0-monitoring-inside-virtual-machines). Denne kan eksponere den underliggende RAPL-informasjonen til en VirtualBox- eller VMWare-instans. En annen mulighet er [Scaphandre](https://github.com/hubblo-org/scaphandre), som gir et Prometheus-grensesnitt inn i energimåling.

Men vi har strengt tatt ikke løst problemet.

* Er det noen måte dette **kan** løses på?


### Linux
En utfordring på Linux er at Java gjerne ikke er installert for root. 
```shell
$ java -version
openjdk version "21.0.3" 2024-04-16 LTS
OpenJDK Runtime Environment Temurin-21.0.3+9 (build 21.0.3+9-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.3+9 (build 21.0.3+9-LTS, mixed mode, sharing)
$ sudo !!
sudo java -version
[sudo] password for martin: 
sudo: java: command not found
```

Vi trenger heldigvis bare tilgang til selve programmet 'java', og så kan vi bruke full sti uten å måtte sette opp full JDK-støtte for root.

```shell
sudo $JAVA_HOME/bin/java -javaagent:joularjx-3.0.0.jar -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution ../1brc/measurements.txt
```

Merk at JAVA_HOME ikke nødvendigvis peker på den samme Java-installasjonen som Maven bruker:

```shell
$ echo $JAVA_HOME
/home/martin/.sdkman/candidates/java/current
$ mvn --version
Apache Maven 3.9.6 (bc0240f3c744dd6b6ec2920b3cd08dcc295161ae)
Maven home: /home/martin/.sdkman/candidates/maven/current
Java version: 21.0.3, vendor: Eclipse Adoptium, runtime: /home/martin/.sdkman/candidates/java/21.0.3-tem
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "6.8.0-39-generic", arch: "amd64", family: "unix"
```

JAVA_HOME peker på /home/martin/.sdkman/candidates/java/current, mens maven finner java i /home/martin/.sdkman/candidates/java/21.0.3-tem. Siden jeg bruker [SDKMAN](https://sdkman.io/), er den første en soft link til den siste. Ditt oppsett kan gi litt forskjellie resultater.

### Windows

Windows krever litt mer programvare for å kunne kjøre Java-agenten. RAPL er nemlig ikke direkte tilgjengelig. 

#### Visual C++ Redistributable
Denne er tilgjenelig fra Microsoft her: https://aka.ms/vs/17/release/vc_redist.x64.exe
Beskrivelse finnes her: https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170

#### RAPL-driver
RAPL-driveren finnes her: https://github.com/hubblo-org/windows-rapl-driver. Den er ikke signert, så den krever litt konfigurasjon av Windows for å godta usignerte drivere. Det betyr også er restart av maskinen. Alt er beskrevet i README.md i hubblo-org-repoet.

#### PowerMonitor
PowerMonitor er et interface mellom RAPL-driveren og Java-agenten. Denne kan lastes ned her: https://github.com/joular/WinPowerMonitor. Hvis du ikke lagrer den i "C:\joularjx", må du oppdatere config.properties-filen til å peke på rett sted.

#### Kjøring
Nå kan vi kjøre applikasjonen på Windows med:
```shell
java -javaagent:joularjx-3.0.0.jar -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution ../1brc/measurements.txt
```

## Oppgave 4

Resultatet hos meg blir da noe slikt som:
```
08/08/2024 05:06:57.909 - [INFO] - +---------------------------------+
08/08/2024 05:06:57.910 - [INFO] - | JoularJX Agent Version 3.0.0    |
08/08/2024 05:06:57.910 - [INFO] - +---------------------------------+
08/08/2024 05:06:57.925 - [INFO] - Results will be stored in joularjx-result/2060117-1723129617923/
08/08/2024 05:06:57.936 - [INFO] - Initializing for platform: 'linux' running on architecture: 'amd64'
08/08/2024 05:06:57.947 - [INFO] - Please wait while initializing JoularJX...
08/08/2024 05:06:58.963 - [INFO] - Initialization finished
08/08/2024 05:06:58.965 - [INFO] - Started monitoring application with ID 2060117

{Abéché=30.8/30.8/30.8, Albuquerque=16.7/16.7/16.7, ... }

08/08/2024 05:07:00.080 - [INFO] - Thread CPU time negative, taking previous time + 1 : 1 for thread: 1
08/08/2024 05:07:00.101 - [INFO] - JoularJX finished monitoring application with ID 2060117
08/08/2024 05:07:00.102 - [INFO] - Program consumed 5.81 joules
08/08/2024 05:07:00.109 - [INFO] - Energy consumption of methods and filtered methods written to files
```

JoularJX rapporterer nå energiforbruket i terminalen (her 5,81 joules). I tillegg opprettes det en katalog 'joularjx-result'. 
Under der lages det en katalog for hver joularjx-kjøring. Her 2060117-1723129617923, der 2060117 er prosess-id'en som kjøres
og 1723129617923 er tidspunktet kjøringen startet (Unix epoch for 8. august, 2024 17:06:57.923 GMT+02:00 CEST). 
Det lagres mye informasjon om kjøringen i filene under her. For eksempel kan vi se på filen joularJX-*-all-methods-energy.csv' i
'joularjx-result/*/all/total/methods'. Denne inneholder en liste av alle metoder som er kalt, og hvor mye
energi hver brukte.

* Hvilke metoder er dyrest?

## Oppgave 5

Vi kan selvsagt se på den dyreste metoden og optimalisere den. Men JVM har en del interessante triks i ermet som vi kan prøve først. Den aller enkleste endringen er å bruke parallelle streams i Java. Dette gjøres enkelt og greit med
å legge til '.parallel()' før kallet til '.map()' på linje 68 i Solution.java.

* Bygg applikasjonen på nytt
* Sammenlign tidsforbruk på de to versjonene
* Sammenlign energiforbruk på de to versjonene
* Er forholdet mellom tid og energi som forventet?

## Oppgave 6

Javascript


# Kode og opphavsrett

## Java-kode

Jeg har kopiert koden fra https://github.com/gunnarmorling/1brc.git, frem til
commit [647d0c5](https://github.com/gunnarmorling/1brc/tree/647d0c578ecffe2880ab50195e747d87f0259557). I tillegg har jeg tatt med to oppdateringer på
CreateMeasurements.java:
* [7d485d0](https://github.com/gunnarmorling/1brc/commit/7d485d0e8b4164e1e5ce09e6ffe30d9de8f9ae7a)
* [38fc317](https://github.com/gunnarmorling/1brc/commit/38fc3170731e82d1c6168cd6ca744cff9c433855)

Til slutt har jeg tatt med siste versjon av pom.xml per [db06419](https://github.com/gunnarmorling/1brc/tree/db064194be375edc02d6dbcd21268ad40f7e2869), men da bare oppdateringene i pom.xml.

Det er mange mennesker som har opphavsrett til denne koden. Vennligst se det opprinnelige [repo på GitHub](https://github.com/gunnarmorling/1brc.git) for dette.