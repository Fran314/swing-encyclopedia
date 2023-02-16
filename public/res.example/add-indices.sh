#!/bin/bash

for s in boogie-woogie lindy-hop lindy-fast; do
    echo -n "" > $s/passi/index
    for f in $s/passi/*.md; do
        if [[ $f =~ $s/passi/(.*).md ]]; then
            echo ${BASH_REMATCH[1]} | tr "_" " " >> $s/passi/index
        fi
    done

    echo -n "" > $s/video/index
    for f in $s/video/*.mp4; do
        if [[ $f =~ $s/video/(.*).mp4 ]]; then
            echo ${BASH_REMATCH[1]} | tr "-" "/" >> $s/video/index
        fi
    done
done
