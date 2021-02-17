#!/bin/bash


# given an input list of directories/files delimited by colon ":" , 
# finds all jars and classes within those directories 

# and identifies all: 
#		- duplicated jars
#		- duplicated classes
# as its origin.



VERBOSE=0

# parse input parameters
for i in "$@"
do
case $i in
    -cp|--classpath)
        if [ -z $2 ]
        then
            echo "--classpath option requires an argument..."
            exit 1
        fi
        CLASSPATH=$2
        shift # past argument=value
        break
        ;;
    -v|--verbose)
        VERBOSE=1
	shift
        ;;
    -h|--help|*)
            echo " Usage:"
            echo "    -h ,  --help                        : show this info"
            echo "    -v ,  --verbose                     : outputs more info and details than normal"
            echo "    -cp , --classpath                   : the desired classpath to search within"

        echo ""
        echo " Find duplicates jars/classes app"
        echo " ============================================================================================================"
        echo "   Given a classpath as an input list of directories/files delimited by colon (:),"
        echo "   finds and reports all duplicated jars or/and classes within those directories/files"
        echo "   Usage example:"
        echo "                          ./findDuplicatedClasses.sh -cp /dirA/file.jar:/dirB/subdirB:/dirC"
        echo ""
        exit 0
        shift # past argument=value
        ;;
esac
done


if [ -z $CLASSPATH ]
then
    echo "error: classpath is not specified. (usage: -cp <classpath>)."
    echo ""
    echo "type './findDuplicatedClasses -h'  for more info/help."
    echo "exiting ..."
    exit 1
fi


if [ $VERBOSE = 1 ]
then
	echo ""
	echo "CLASSPATH="
	echo "$CLASSPATH"
	echo ""
fi


#
## Script Start


DIR_LIST=$(for i in $(echo $CLASSPATH | tr ':' '\n'); do find $i; done | sort | uniq)


if [ $VERBOSE = 1 ]
then
	echo "Directories/files list:"
	echo "$DIR_LIST"
	echo ""
fi

echo "Looking up for all jar files ..."


JARS_LIST=$(for i in $(echo $CLASSPATH | tr ':' '\n'); do find $i; done | sort | uniq | grep .jar)


if [ $VERBOSE = 1 ]
then
	echo "JARs found:"
	echo "$JARS_LIST"
	echo ""
fi


# get jars basename list and origin reference map
declare -A JARS_BASENAME_ORIGIN

for i in $JARS_LIST
do
	BASENAME=$(basename $i)
	JARS_LIST_BASENAME=$JARS_LIST_BASENAME$'\n'$BASENAME
	JARS_BASENAME_ORIGIN[$BASENAME]=${JARS_BASENAME_ORIGIN[$BASENAME]}$'\n'$i
done


if [ $VERBOSE = 1 ]
then
	echo "JARs basenames found:"
	echo "$JARS_LIST_BASENAME"
	echo ""
fi



echo "Finding jar files basenames duplicates..."

JARS_DUPLIC_LIST=$(echo "$JARS_LIST_BASENAME" | sort | uniq -cd)


# if duplicates are found, print details 
if [ -z "$JARS_DUPLIC_LIST" ]
then
	echo "No duplicates were found ..."
else
	echo "JARs basenames duplicates found:"
	echo "$JARS_DUPLIC_LIST"
	echo ""
	echo "     Details:"
	for x in $(echo "$JARS_LIST_BASENAME" | sort | uniq -d)
	do
		echo "      - "$x
		echo "              originated in:"${JARS_BASENAME_ORIGIN[$x]}
	done
	echo ""
fi


echo "Gathering all classes inside the jar files ..."

# get jars basename list and origin reference map
declare -A ALL_CLASS_ORIGIN_JAR

for i in $JARS_LIST
do
	CLASS_INSIDE=$(jar tf $i | grep .class)
	CLASSES_LIST=$CLASSES_LIST$'\n'$CLASS_INSIDE

	# fill reference map
	for j in $CLASS_INSIDE
	do
		ALL_CLASS_ORIGIN_JAR[$j]=${ALL_CLASS_ORIGIN_JAR[$j]}$'\n'$i
	done
done



#CLASSES_LIST=$(for i in $JARS_LIST; do jar tf $i; done | grep .class | sort)


if [ $VERBOSE = 1 ]
then
	echo "Classes found:"
	echo "$CLASSES_LIST"
	echo ""
fi



echo "Finding classes duplicates..."

CLASS_DUPLIC_LIST=$(echo "$CLASSES_LIST" | sort | uniq -cd)


if [ -z "$CLASS_DUPLIC_LIST" ]
then
	echo "No duplicates were found ..."
else
	echo "Classes duplicates found:"
	echo "$CLASS_DUPLIC_LIST"
	echo ""
	echo "     Details:"
	for x in $(echo "$CLASSES_LIST" | sort | uniq -d)
	do
		echo "      - "$x
		echo "              originated in:"${ALL_CLASS_ORIGIN_JAR[$x]}
	done
	echo ""


fi



echo ""
echo "Terminated successfully..."


exit 0

