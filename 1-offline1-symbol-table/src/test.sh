rm 1805052.out
g++ -Werror -g 1805052.cpp -o 1805052.out
valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --verbose \
         --log-file=valgrind-out.txt \
         ./1805052.out