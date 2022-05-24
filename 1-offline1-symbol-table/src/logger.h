#pragma once
#include<string>
using namespace std;

#define tag(msg) string(__FILE__) + " Line#" + to_string(__LINE__) + " " + msg + string(__FUNCTION__) + "-> "
#define log(tag, ...) \
    logger2(tag);     \
    logger1(#__VA_ARGS__, __VA_ARGS__);
template <typename... Args>
void logger1(string vars, Args &&...values)
{
    cout << vars << " = ";
    string delim = "";
    (..., (cout << delim << values, delim = ", "));
    cout << endl;
}

template <typename... Args>
void logger2(Args &&...values)
{
    string delim = "";
    (..., (cout << delim << values, delim = " "));
}
