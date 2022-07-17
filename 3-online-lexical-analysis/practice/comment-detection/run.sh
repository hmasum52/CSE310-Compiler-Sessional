flex -o $1.cpp $1.l
g++ $1.cpp -o -lfl -o $1.o
./$1.o $2.txt
rm $1.cpp $1.o