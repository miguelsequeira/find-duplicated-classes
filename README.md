## Find Duplicated Classes Script

Handy tool to identify duplicated dependencies, jars or classes with multiple versions on a java running machine.

 ```
 Find duplicates jars/classes app
  ============================================================================================================
   Given a classpath as an input list of directories/files delimited by colon (:),
   finds and reports all duplicated jars or/and classes within those directories/files
   Usage example:
                          ./findDuplicatedClasses.sh -cp /dirA/file.jar:/dirB/subdirB:/dirC
                          
                          


 Usage:
    - h ,  --help                        : show this info
    - v ,  --verbose                     : outputs more info and details than normal
    - cp , --classpath                   : the desired classpath to search within
```
