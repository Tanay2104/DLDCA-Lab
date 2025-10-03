#!/bin/bash

# Usage: ./check_submission.sh <roll_number>
# Example: ./check_submission.sh 24b0926

ROLL=$1
TARFILE="$ROLL.tar.gz"
DIR="$ROLL"

if [[ -z "$ROLL" ]]; then
    echo "Usage: $0 <roll_number>"
    exit 1
fi

if [[ ! -f "$TARFILE" ]]; then
    echo "File $TARFILE not found in current directory"
    exit 1
fi

rm -rf "$DIR"

tar -xzf "$TARFILE" || { echo "Failed to extract $TARFILE"; exit 1; }

EXPECTED=(
    "$DIR/task1/loops.asm"
    "$DIR/task1/compile.sh"
    "$DIR/task2/tower-of-hanoi.asm"
    "$DIR/task2/compile.sh"
)

STATUS=0
for f in "${EXPECTED[@]}"; do
    if [[ -f "$f" ]]; then
        echo "Found $f"
    else
        echo "Missing $f"
        STATUS=1
    fi
done

if [[ $STATUS -eq 0 ]]; then
    echo "Structure for $ROLL is correct."
else
    echo "Structure for $ROLL is incorrect."
fi

exit $STATUS

