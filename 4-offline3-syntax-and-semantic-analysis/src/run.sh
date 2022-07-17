yacc --yacc -d 1805052-parser.y -o y.tab.cpp
echo 'step-1: y.tab.cpp and y.tab.hpp created'
flex -o 1805052.cpp 1805052-scanner.l
echo 'step-2: scanner created'
g++ -w *.cpp
echo 'step-3: a.out created'
rm 1805052.cpp y.tab.cpp y.tab.hpp
./a.out input.txt
rm a.out 

# yacc -d -y 1805052-parser.y -o y.tab.cpp
# echo 'Generated the parser Cpp file as well the header file'
# g++ -w -c -o y.o y.tab.cpp
# echo 'Generated the parser object file'
# flex -o 1805052.cpp 1805052-scanner.l
# echo 'Generated the scanner Cpp file'
# g++ -w -c -o l.o 1805052.cpp
# # if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
# echo 'Generated the symbol table object files'
# g++ y.o l.o -lfl
# echo 'All ready, running'
# ./a.out