# Oracle-DB-Compile-Invalid-Objects

## Introduction
This repository contains code that lets you compile all the invalids within a database. 
There are a few ways you could compile an invalid object such as using `dbms_ddl.alter_compile` or `utl_recomp.recomp`. With past experiences, these methods are unreliable and do not always compile an object properly and even ignore synonyms. The best way from my personal experience is to recompile an object manually i.e. `ALTER object_type schema.object COMPILE`. This script automates the manual process of recompiling objects including missed synonyms.

## Usage
To use the provided script you can either run the code directly though your IDE (e.g. SQLDeveloper) or using SQLPlus with the command:
`sqlplus apps/apps @"compile_invalids.sql"`

## Contributing
Contributions are welcome whether it is for small bug fixes or new pieces of major functionality. To contribute changes, you should first fork the upstream repository to your own GitHub account. You can then add a new remote for `upstream` and rebase any changes you make and keep up-to-date with the upstream.

`git remote add upstream https://github.com/surajkumar/oracle-db-compile-invalid-objects.git`
