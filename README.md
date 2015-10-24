Tomcat Instance Manager
=======================

Manage multiple Tomcat instances on Windows using a Tomcat single installation.

*Previously hosted on [Google code](https://code.google.com/p/tomcat-instance-manager/). Going forward, it will be maintained on Github.*

## Download and Installation
We may clone this repository or just [Download](https://github.com/kdabir/tomcat-instance-manager/archive/master.zip) and extact the zip at desired location.

Set the Environment Variable `CATALINA_HOME` to point to our Tomcat installation directory (not the Tomcat Instance manager scripts dir) and also set `JAVA_HOME` to point to Java installation.


## Purpose

*Tomcat Instance Manager* helps us create and manage multiple tomcat instance using same tomcat binaries. Different webapps/ services can be then installed on different instances. All instances are isolated from each other, started on different ports and can be started/stopped/restarted without affecting other instances. 

Tomcat can run out of same binaries with different configuration for each instance/environment. With tomcat instance manager, we can easily create multiple instances without having to install tomcat multiple times.

It also lets us create windows services per instance, so that we don't need to start/stop each instance from command line (we can still do so if we want to). Installing service has its own pros and cons, which need not be discussed here.

Examples when Tomcat Instance Manger comes handy

- We have two or more apps to run, let's say one REST API and a webapp that consumes the API. With Tomcat Instance Manager we can deploy all apps on different instances of tomcat.
- When keeping one app always on, we need to develop test other apps such that one can be started as a background service whereas other instance can be used for development and restarted as necessary. 
- Simulating two different environments for a same app (let's say QA and Dev). 
- Just want to create a throwaway tomcat configuration without modifying our existing installation.
- Deploying two different versions of same app and running them side-by-side to see differences.


## Usage

    > tomcat6
    USAGE :
            tomcat6 create-instance {instance-name} {install-path}
                    [service-name] [service-display-name] [service-description]
            tomcat6 remove-instance {instance-name} {install-path}
            tomcat6 start | stop | restart | clean
            tomcat6 service start | stop | restart | run-in-console
            tomcat6 service install | remove | edit | monitor
            where {var} - mandatory param  [var] - optional param

Example: once we download the project, we would have tomcat6/tomcat7 `.bat` files in the directory. Lets say we extract tomcat-instance-manager to `D:\scripts\`

Now we want to create two instances of tomcat, calling it `default` instance (for some app to keep running on this instance, e.g. some REST services) and other as `dev` instance (which can be used to test the apps we are developing)

### Creating instances

*Creating `dev` instance*

    D:\scripts>tomcat6 create-instance tomcat-dev d:\etc\tomcat-profiles tcdev "Tomcat dev Instance"
    D:\sdk\tomcat-6.0\conf\catalina.policy
    D:\sdk\tomcat-6.0\conf\catalina.properties
    D:\sdk\tomcat-6.0\conf\context.xml
    D:\sdk\tomcat-6.0\conf\logging.properties
    D:\sdk\tomcat-6.0\conf\server.xml
    D:\sdk\tomcat-6.0\conf\tomcat-users.xml
    D:\sdk\tomcat-6.0\conf\web.xml
            7 file(s) copied.
    Instance created successfully : d:\etc\tomcat-profiles\tomcat-dev
    Instance handler script created successfully

*Creating `default` instance*

    D:\scripts>tomcat6 create-instance tomcat-default d:\etc\tomcat-profiles tcdefault "Tomcat default Instance"
    D:\sdk\tomcat-6.0\conf\catalina.policy
    D:\sdk\tomcat-6.0\conf\catalina.properties
    D:\sdk\tomcat-6.0\conf\context.xml
    D:\sdk\tomcat-6.0\conf\logging.properties
    D:\sdk\tomcat-6.0\conf\server.xml
    D:\sdk\tomcat-6.0\conf\tomcat-users.xml
    D:\sdk\tomcat-6.0\conf\web.xml
            7 file(s) copied.
    Instance created successfully : d:\etc\tomcat-profiles\tomcat-default
    Instance handler script created successfully

### Starting / Stopping instances

*Starting `default` instance*

    D:\scripts>tomcat-default start
    Using CATALINA_BASE:   d:\etc\tomcat-profiles\tomcat-default
    Using CATALINA_HOME:   D:\sdk\tomcat-6.0
    Using CATALINA_TMPDIR: d:\etc\tomcat-profiles\tomcat-default\temp
    Using JRE_HOME:        D:\sdk\jdk-1.6
    Using CLASSPATH:       D:\sdk\tomcat-6.0\bin\bootstrap.jar
    SERVER STARTED (IN A SEPERATE WINDOW)

*Stopping `default` instance*

    D:\scripts>tomcat-default stop
    Using CATALINA_BASE:   d:\etc\tomcat-profiles\tomcat-default
    Using CATALINA_HOME:   D:\sdk\tomcat-6.0
    Using CATALINA_TMPDIR: d:\etc\tomcat-profiles\tomcat-default\temp
    Using JRE_HOME:        D:\sdk\jdk-1.6
    Using CLASSPATH:       D:\sdk\tomcat-6.0\bin\bootstrap.jar
    SERVER STOPPED

### Installing as Windows service

*Installing `default` instance as service*

    D:\scripts>tomcat-default service install
    SERVICE 'tcdefault'-'Apache Tomcat 'tomcat-default' instance based at d:\etc\tomcat-profiles\tomcat-default' INSTALLED SUCCESSFULLY

*Installing `dev` instance as service*

    D:\scripts>tomcat-dev service install
    SERVICE 'tcdev'-'Apache Tomcat 'tomcat-dev' instance based at d:\etc\tomcat-profiles\tomcat-dev' INSTALLED SUCCESSFULLY

### Starting / Stopping service

*Starting `dev` instance as service*

    D:\scripts>tomcat-dev service start
    The Tomcat Dev Instance service is starting..
    The Tomcat Dev Instance service was started successfully.

*Stopping the `dev` instance as service*

    D:\scripts>tomcat-dev service stop
    The Tomcat Dev Instance service was stopped successfully.

### Monitor an installed instance service

*Monitoring the `dev` instance service*

    D:\scripts>tomcat-dev service monitor

### Editing a service

*Editing the `dev` instance service*

    D:\scripts>tomcat-dev service edit
