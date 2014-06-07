# XQuery Institute Demo Application

This is an XQuery application for searching the plays of Shakespeare.

## Getting started

After cloning this Git repository:

    git clone https://github.com/CliffordAnderson/shakespeare-search.git

Or downloading the source from:

    https://github.com/CliffordAnderson/shakespeare-search/archive/master.zip

The application can be installed by 1) creating and installing a XAR file or by 2) running an installation script.

To create the XAR file, run `ant` from within the project directory:

    cd shakespeare-search
    ant

This will create a .xar file at `${project.dir}/build/xq-institute-0.1.xar`  This XAR file can then be uploaded into eXist-db using the Web-based package manager: [http://localhost:8080/exist/apps/dashboard/index.html](http://localhost:8080/exist/apps/dashboard/index.html)

Alternatively, the project can be uploaded into eXist-db through the project's Ant script.  To do this, create a build.properties file by copying the example properties file to a file named `build.properties`:

    cp build.properties.example build.properties

You can then edit the values in that file to match your environment (e.g., your database `username` and `password`). Once you've configured the build, you can run the following from the command line:

    ant update-db
    ant reindex-plays

This will install the files in your database and reindex the plays.  Ant can also be used to copy files you've edited in the database back to the file system:

    ant dump-db-files

Note that running `update-db` will overwrite any database files with versions from the file system.  Running `dump-db-files` will overwrite files on the file system with versions from the database.

As an aside, Git can be really useful for managing the differences between the file system and database files.  If changes on the file system have been committed to Git before the dump-db-files script is run, then `git diff` can be used to manage the differences that have been introduced by dumping the database files.  It's advised to create a separate Git branch in which to manage the differences.  If you are not familiar with Git, don't worry; it's not required to use this application.  It's just mentioned as one way to manage changes between the file system and the eXist database.

## Potential Gotchas

If you haven't already, make sure you install the FunctX XQuery library (available through eXist-db's Web-based package manager):

[http://localhost:8080/exist/apps/dashboard/index.html](http://localhost:8080/exist/apps/dashboard/index.html)
