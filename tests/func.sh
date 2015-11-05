#!/bin/bash

check_outputs () {
    command="$@"
    hashed=$(echo -n "${command}" | md5sum | cut -d" " -f1)
    
    ${command} > orig_${hashed}_stdout.txt 2> orig_${hashed}_stderr.txt
    echo "$?" > orig_${hashed}_exitcode.txt
    
    cd ..
    ./mock ${command} 2>&1 > /dev/null
    
    cd mocks
    ./${command} > ../tests/mock_${hashed}_stdout.txt 2> ../tests/mock_${hashed}_stderr.txt
    echo "$?" > ../tests/mock_${hashed}_exitcode.txt
    cd ../tests
    
    outcome=0
    
    echo "Checking stdout.."
    diff orig_${hashed}_stdout.txt mock_${hashed}_stdout.txt
    if [ $? -ne 0 ]; then
        echo "FAIL: stdouts differ"
        outcome=1
    fi
    
    echo "Checking stderr.."
    diff orig_${hashed}_stderr.txt mock_${hashed}_stderr.txt
    if [ $? -ne 0 ]; then
        echo "FAIL: stderrs differ"
        outcome=1
    fi
    
    echo "Checking exit code.."
    diff orig_${hashed}_exitcode.txt mock_${hashed}_exitcode.txt
    if [ $? -ne 0 ]; then
        echo "FAIL: exitcodes differ"
        outcome=1
    fi
    
    rm orig_${hashed}_*
    rm mock_${hashed}_*
    
    return $outcome
}