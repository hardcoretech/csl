#!/bin/bash

echo "********** CSL server - Start import source list **********"

## define source name array ##
souces=(
    "CapData"
    "DplData"
    # "DtcData"
    "ElData"
    "FseData"
    # "IsnData"
    "MeuData"
    "PlcData"
    "SdnData"
    "SsiData"
    "UvlData"
)

## get item count using ${arrayname[@]} ##
for source in "${souces[@]}"
do
  echo "********** Import $source **********"
  bundle exec rake ita:import_synchronously[ScreeningList::$source]
done

echo "********** CSL server - Finish import source list **********"
