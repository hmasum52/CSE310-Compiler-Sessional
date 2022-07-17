rm 1805052_log.txt 1805052_token.txt
flex -o 1805052.cpp 1805052.l
g++ 1805052.cpp -o -lfl -o a.out
./a.out input.txt
rm a.out 1805052.cpp