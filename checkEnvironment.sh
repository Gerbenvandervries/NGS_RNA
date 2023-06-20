HOST=$1

if [[ -f ./environment_checks.txt ]]
then
	rm ./environment_checks.txt
fi

ENVIRONMENT_PARAMETERS=""
TMPDIR=""
GROUP=""
if [ "${HOST}" == "zinc-finger.gcc.rug.nl" ]
then
	ENVIRONMENT_PARAMETERS="zinc-finger"
	TMPDIR="tmp05"
elif [ "${HOST}" == "leucine-zipper.gcc.rug.nl" ]
then
	ENVIRONMENT_PARAMETERS="leucine-zipper"
	TMPDIR="tmp06"
else
	echo "Unknown host: running is only possible on zinc-finger or leucine-zipper."
fi

THISDIR=$(pwd)
if [[ $THISDIR == *"/groups/umcg-gaf/"* ]]
then
	GROUP="umcg-gaf" 
elif [[ $THISDIR == *"/groups/umcg-gd/"* ]]
then
	GROUP="umcg-gd"
else
	echo "This is not a known group. Please run only in umcg-gd or umcg-gaf group."
fi

printf "${ENVIRONMENT_PARAMETERS}\t${TMPDIR}\t${GROUP}" > ./environment_checks.txt
