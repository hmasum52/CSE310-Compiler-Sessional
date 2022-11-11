int main()
{
    int x, c[3];
    c[0] = 5;
    c[1] = 6;
    c[2] = c[0] * c[1];
    int a;
    a = c[2];
    println(a);
    a = a / 2;
    println(a);
    a = a % 3;
    println(a);
}