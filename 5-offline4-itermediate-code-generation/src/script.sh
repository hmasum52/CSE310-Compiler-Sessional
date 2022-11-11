    yacc --yacc -d 1805052-parser.y -o y.tab.cpp
    echo 'step-1: y.tab.cpp and y.tab.hpp created'
    flex -o 1805052.cpp 1805052-scanner.l
    echo 'step-2: scanner created'
    g++ -w *.cpp
    echo 'step-3: a.out created'
    rm 1805052.cpp y.tab.cpp y.tab.hpp
    ./a.out $1
    rm a.out 

    # ./script.sh ../Sample-input/<test_file>.c