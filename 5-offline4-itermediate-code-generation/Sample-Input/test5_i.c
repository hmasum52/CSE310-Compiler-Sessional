int f(int a){ // a = 1
    int k;
    k = 5;
    while(k>0){

        a++; // a = 2->3->4->5
        k--;
    }
    return 3*a - 7;
    a=9;
}

int g(int a, int b){

    int x,i;
    x=f(a)+a+b; // x = 14, f(a) = 11, a = 1 , b = 2
    for(i=0;i<7;i++){
        if(i%3 == 0){
            x = x+5;
        }
        else{
            x = x-1;
        }
    }
    return x;
}

int main()
{
    int a, b, i;
    a = 1;
    b = 2;
    a=g(a,b);
    println(a); // 25
    println(b); // 2
    for(i=0;i<4;i++){
        a=3;
        while(a>0){
            b++;
            a--;
        }
    }
    println(a); // 0
    println(b); // 14
    println( i); // 4 
    return 0;
}
