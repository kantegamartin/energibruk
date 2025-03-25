# Optimizing for Sustainability

In this workshop, we'll explore how to measure the energy consumption of our code. We can use this to observe consumption reduction when optimizing code, or to compare implementations across different programming languages. 

The simplest way to complete this workshop is to use Java on either MacOS or Linux. The workshop includes some optimization examples in Java, so expertise in the language isn't necessary. Just ensure that mvn --version and java -version refer to the same Java version. 

Regarding Windows, measuring CPU energy consumption requires installing an unsigned kernel driver. This means Windows must be set to test mode. Neither of these is recommended, so it might be better to work with someone who has Linux or MacOS. It is also possible to assume that time is a decent proxy for energy consumtion, and just time the various runs.

The workshop also includes examples using NodeJS and PostgreSQL. These don't provide as much code information as the Java version. However, their measurements are more generic. If you want to look at implementations in other languages like Python or Rust, the technique described there can be used.


## Example Code 

The starting point is [The One Billion Row Challenge](https://www.morling.dev/blog/one-billion-row-challenge/). This is a simple problem that involves reading a file containing 1 billion temperature measurements as quickly as possible and outputting the measuring stations in alphabetical order with their minimum, average, and maximum temperatures. 

The code from the challenge is located in the `1brc/java` directory. This code is licensed under the Apache 2.0 license. See the section at the bottom about 'Code and Copyright' for more information about the copyright of this code. 

# Tasks

## Task 1 

The first requirement is to create a file with measurements that can be read. This is done by building `1brc/java` with Java 24 and Maven 3.9.9. Then run the resulting jar file with a parameter specifying the number of rows to generate. 

The simplest approach is to run the `createMeasurements.sh` script in the 1brc folder:
```shell
./createMeasurements.sh 100
```
If bash isn't available, run the generation using standard Java commands:
```shell
mvn package
java -cp target/average-1.0.0-SNAPSHOT.jar dev.morling.onebrc.CreateMeasurements 100
```
The resulting file `measurements.txt` will contain 100 rows and can be used in subsequent tasks. It's advisable to create different variants with varying numbers of rows. Running the baseline code with 100 million rows takes over 20 seconds on my machine. Running the full billion rows, should probably wait for more optimized code.

## Task 2

There's a simple Java implementation in the `java` folder. This reads all lines in the file, splits each line on semicolon, and creates an instance of the `Measurement` class for each line. It then uses a `Collector` to group by station name and aggregate min, max, and average in a `MeasurementAggregator`. Finally, the result is stored in a `ResultRow` where the result is sorted using a `TreeMap` before being output. 70 lines and nothing fancy. 

This needs to be built and run: 
```shell
mvn package
java -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution ../1brc/measurements.txt
# Can also time it using the 'time' command:
time java -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution ../1brc/measurements.txt
```

A script `timeRun.sh` is included that takes a filename as a parameter and times the execution. 

Try with files of different sizes if you'd like. 

## Task 3 

[JoularJX](https://www.noureddine.org/research/joular/joularjx) is a Java agent that measures the energy consumption of an application during runtime. Version 3.0.1 is included in the repo. The agent uses Intel's RAPL (Running Average Power Limit) interface to read the application's energy usage during runtime. Since this accesses the processor's core functionality, it's only available via privileged access. This means we need to download and install drivers and tools from GitHub and run them in administrator mode. There are many red flags here! 

A script `joularRun.sh` is included that attempts to find a working Java installation and run it as 'root' with the joularjx agent. Like `timeRun.sh`, it takes a filename as a parameter, which specifies which file to read. 


### Virtual Machine? 

Running this in a virtual machine works quite poorly, as actual energy consumption must be obtained from a physical processor. It's possible to install something like [PowerJoular](https://www.noureddine.org/articles/powerjoular-1-0-monitoring-inside-virtual-machines). This can expose the underlying RAPL information to a VirtualBox or VMWare instance. Another option is [Scaphandre](https://github.com/hubblo-org/scaphandre), which provides a Prometheus interface for energy measurement. 

But we haven't really solved the problem. 

* Is there any way this **can** be solved? 

### Linux / macOS 

One challenge is that Java is typically not installed for root:
```shell
$ java -version
openjdk version "24" 2025-03-18
OpenJDK Runtime Environment Temurin-24+36 (build 24+36)
OpenJDK 64-Bit Server VM Temurin-24+36 (build 24+36, mixed mode, sharing)
$ sudo !!
sudo java -version
[sudo] password for martin:
sudo: java: command not found
```

Fortunately, we only need access to the `java` executable itself, and we can use the full path without needing to set up full JDK support for root. 
```shell
sudo $JAVA_HOME/bin/java -javaagent:joularjx-3.0.1.jar -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution ../1brc/measurements.txt
```
Note that JAVA_HOME might not point to the same Java installation that Maven uses. 
```shell
$ echo $JAVA_HOME
/home/martin/.sdkman/candidates/java/current
$ mvn --version
Apache Maven 3.9.9 (8e8579a9e76f7d015ee5ec7bfcdc97d260186937)
Maven home: /home/martin/.sdkman/candidates/maven/current
Java version: 24, vendor: Eclipse Adoptium, runtime: /home/martin/.sdkman/candidates/java/24-tem
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "6.11.0-21-generic", arch: "amd64", family: "unix"
```

`JAVA_HOME` is pointing at /home/martin/.sdkman/candidates/java/current, while maven finds java in /home/martin/.sdkman/candidates/java/24-tem. I'm using [SDKMAN](https://sdkman.io/), so the first is a soft link to the latter. Your setup might have slightly different issues.


### Windows 

Windows requires additional software to run the Java agent, as RAPL is not directly accessible. 

#### Visual C++ Redistributable 

This is available from Microsoft here: https://aka.ms/vs/17/release/vc_redist.x64.exe 
Description can be found here: https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170  

#### RAPL Driver 

The RAPL driver is available here: https://github.com/hubblo-org/windows-rapl-driver . It's unsigned, so it requires Windows configuration to accept unsigned drivers. This also means a machine restart. Everything is described in the README.md in the hubblo-org repo. 

#### PowerMonitor 

PowerMonitor is an interface between the RAPL driver and the Java agent. This can be downloaded here: https://github.com/joular/WinPowerMonitor . If you don't store it in "C:\joularjx", you'll need to update the config.properties file to point to the correct location. 

#### Running 

Now we can run the application on Windows with: 
```shell
java -javaagent:joularjx-3.0.1.jar -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution ../1brc/measurements.txt
```

Task 4 

The result on my machine looks something like this:
```
Kjører java fra '/home/martin/.sdkman/candidates/java/current/bin/java':
openjdk version "24" 2025-03-18
OpenJDK Runtime Environment Temurin-24+36 (build 24+36)
OpenJDK 64-Bit Server VM Temurin-24+36 (build 24+36, mixed mode, sharing)
25/03/2025 05:28:18.537 - [INFO] - +---------------------------------+
25/03/2025 05:28:18.538 - [INFO] - | JoularJX Agent Version 3.0.1    |
25/03/2025 05:28:18.538 - [INFO] - +---------------------------------+
25/03/2025 05:28:18.553 - [INFO] - Results will be stored in joularjx-result/219079-1742920098552/
25/03/2025 05:28:18.557 - [INFO] - Initializing for platform: 'linux' running on architecture: 'amd64'
25/03/2025 05:28:18.571 - [INFO] - Please wait while initializing JoularJX...
25/03/2025 05:28:19.585 - [INFO] - Initialization finished
25/03/2025 05:28:19.587 - [INFO] - Started monitoring application with ID 219079

{Abha=2.0/15.7/31.8, Abidjan=27.7/29.8/31.8, ... İzmir=8.9/15.5/21.7}

25/03/2025 05:28:20.729 - [INFO] - Thread CPU time negative, taking previous time + 1 : 1 for thread: 3
25/03/2025 05:28:20.783 - [INFO] - JoularJX finished monitoring application with ID 219079
25/03/2025 05:28:20.783 - [INFO] - Program consumed 5.92 joules
25/03/2025 05:28:20.823 - [INFO] - Energy consumption of methods and filtered methods written to files

```

JoularJX now reports the energy consumption in the terminal (here 5.92 joules). Additionally, a directory 'joularjx-result' is created.
Under this, a directory is created for each joularjx run. Here 219079-1742920098552, where 219079 is the process ID being run
and 1742920098552 is the timestamp when the run started (Unix epoch for Tue, 25 Mar 2025 17:31:54 CEST).
Lots of information about the run is stored in the files here. For example, we can look at the file 'joularJX--all-methods-energy.csv' in
'joularjx-result//all/total/methods'. This contains a list of all methods called and how much
energy each used. 

* Which methods are the most expensive?

## Task 5 

We can of course look at the most expensive method and optimize it. But the JVM has some interesting tricks up its sleeve that we can try first. The simplest change is to use parallel streams in Java. This is done simply by adding `.parallel()` after the `.map()` call on line 66 in Solution.java. 

1. Build the application again
1. Compare time consumption between the two versions
1. Compare energy consumption between the two versions
1. Is the relationship between time and energy as expected?

## Task 6 

There's also a solution in Javascript in the `nodejs` directory. This uses the same files that are generated for the Java solution. The code uses Node 20 and can be run with: 
```shell
time node baseline/index.js ../1brc/measurements.txt
```

## Task 7 

To measure energy consuxmption of a Java program, we used a dedicated Java agent. For NodeJS, we can use the generic [PowerJoular](https://github.com/joular/powerjoular), but this currently only supports Linux. 

PowerJoular can be installed and downloaded by either building [the Ada code yourself](https://joular.github.io/powerjoular/ref/compilation.html), or by [downloading the pre-built packages](https://github.com/joular/powerjoular/releases) for Debian or Red Hat. 

PowerJoular measures processor energy consumption in real time. It can be limited to a single process with a -p parameter. Additionally, it can write to a file during execution. 

By running: 
```shell
sudo powerjoular -p $ID -t -f p.out
```
we get the energy consumption of process ID written to both the screen (-t) and to the file p.out (-f). 

PowerJoular reports usage until it's terminated. If the program it's monitoring ends, it fails. So to measure a run, we must: 

1. Start NodeJS in the background and save the process ID
1. Start PowerJoular in the background and save the process ID
1. Send a termination signal to PowerJoular when the node app finishes


A script that does this somewhat awkwardly, powerRun.sh, is included. 

* How can this be improved?

## Taks 8

* How can the Javascript solution be improved?
* What is the relationship between saved energy and saved time?

## Task 9 

There's a solution for PostgreSQL in the postgres-catalog. This relies on first running PostgreSQL in Docker. Then psql is used to run a test script. 

```shell
docker compose up -d
psql postgresql://postgres:postgres@localhost:5432/sustainability -f test.sql
```

Experiment with different datasets until you find one that uses a reasonable execution time. 

## Task 10 

We can use PowerJoular to measure the energy consumption of the docker process while running the test script. This is most easily done by starting powerjoular in a separate window: 

```shell
sudo powerjoular -p $(pidof docker) -t -f p.out
```

Then start the test script as in task 9. When the script is finished, we can interrupt powerjoular to get the total consumption.

```shell
psql postgresql://postgres:postgres@localhost:5432/sustainability -f test.sql
```

## Task 11 

1. Compare creating the index before and after data loading by switching the order of 'CREATE INDEX' and 'COPY' in test.sql
1. What causes the difference?
1. What's the relationship between time and energy consumption here?
     

# Concluding Discussions 

This workshop has demonstrated how we can measure the energy consumption of our applications during development. We can use this to reduce our energy needs. This saves both money and the environment, and often users' time as well.

The applications we create rarely have large volumes. Enterprise applications typically have two or three transactions per second during normal working hours. This could run on a Raspberry Pi. Yet we set up blue-green kubernetes and machines that run 24/7. What is the actual energy requirement for what we've created? What do we introduce when we configure modern infrastructure in the cloud? 

Another question we can ask ourselves is what we're doing when we optimize code. Is something lost? Some of the code changes for 1BRC are quite general. They can even make the code easier to understand. But the fastest solutions break Java's security regime and are highly optimized for exactly the dataset being used. This can make the code less suitable for extensions. Where is this boundary? When is it okay to sacrifice readability for the last half joule of energy? 

We can also ask ourselves whether 'time' is a good proxy for 'energy consumption'. If so, we can use more common profilers during optimization. What are the consequences of this? 


# Code and Copyright

## Java code

I have copied the code from https://github.com/gunnarmorling/1brc.git, up to
commit [647d0c5](https://github.com/gunnarmorling/1brc/tree/647d0c578ecffe2880ab50195e747d87f0259557). Additionally, I included two updates to
CreateMeasurements.java:
* [7d485d0](https://github.com/gunnarmorling/1brc/commit/7d485d0e8b4164e1e5ce09e6ffe30d9de8f9ae7a)
* [38fc317](https://github.com/gunnarmorling/1brc/commit/38fc3170731e82d1c6168cd6ca744cff9c433855)

Finally, I included the latest version of pom.xml as of [db06419](https://github.com/gunnarmorling/1brc/tree/db064194be375edc02d6dbcd21268ad40f7e2869), but only the updates in pom.xml. 

Many people hold copyright to this code. Please see the original [repo on GitHub](https://github.com/gunnarmorling/1brc.git) for this.

## Javascript code

The Javascript code is based on: https://github.com/Edgar-P-yan/1brc-nodejs-bun#submitting.

## PostgreSQL code

The PostgreSQL code is based on: https://ftisiot.net/posts/1brows/