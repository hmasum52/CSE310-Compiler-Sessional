rm 1805052.out
g++ -Werror -g 1805052.cpp -o 1805052.out
valgrind -s --leak-check=full ./1805052.out 
