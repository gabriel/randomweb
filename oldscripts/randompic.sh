#!/bin/bash

usage() {
  echo "$0 [iterations] [directory] [min width] [min height]"
  echo "\nNote: Minimum width and height only supported if Image Magick is installed"
  exit 1
}

N=0
ITERATIONS=5
DIR=images
MIN_HEIGHT=480
MIN_WIDTH=640
IDENTIFY=`which identify 2>/dev/null`

if [ ! "$1" = "" ]; then
  ITERATIONS=$1 
else
  usage
fi

if [ ! "$2" = "" ]; then
  DIR=$2
fi

if [ ! "$3" = "" ]; then
  MIN_WIDTH=$3
fi

if [ ! "$4" = "" ]; then
  MIN_HEIGHT=$4
fi


echo "Saving images to directory: $DIR"
echo "Iterating $ITERATIONS times"

if [ -e "$IDENTIFY" ]; then
  echo "Using image identify at: $IDENTIFY"
  echo "Using min size: $MIN_WIDTH x $MIN_HEIGHT"
fi

while [ $N -lt $ITERATIONS ]
do
  echo "Finding random pic url..."
  url=`perl randompic.pl`
  echo "Getting url: $url"
  wget -P $DIR -t 1 -T 10 -nv $url
  file=$DIR/`echo $url | sed -e "s/\(.*\)\/\(.*\)/\\2/"`
  echo "File: $file"

  if [ -e "$file" ] && [ -e "$IDENTIFY" ]; then
    
    size=`identify $file | cut -d ' ' -f 3` 
    ewidth=`echo $size | cut -d"+" -f1 | cut -d"x" -f1`;
    eheight=`echo $size | cut -d"+" -f1 | cut -d"x" -f2`;
    
    echo "Dimensions: ${ewidth}x${eheight}"

    if [ $ewidth -lt $MIN_WIDTH ]; then
      echo "Discarding, does not meet the mininum width requirement: $MIN_WIDTH"
      rm $file
    elif [ $eheight -lt $MIN_HEIGHT ]; then
      echo "Discarding, does not meet the mininum height requirement: $MIN_HEIGHT"
      rm $file
    fi 
  fi
  N=$((N+1))
done           

