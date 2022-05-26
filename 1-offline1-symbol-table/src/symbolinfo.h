#pragma once
#include<bits/stdc++.h>
using namespace std;


/**
 * This class contains the information regarding a symbol faced
 * in the source program.
 *
 */
class Symbolinfo
{
    string name;
    string type;
    Symbolinfo *next;

public:
    Symbolinfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        this->next = nullptr;
    }

    // copy constructor
    Symbolinfo(const Symbolinfo &other)
    {
        this->name = other.name;
        this->type = other.type;
        this->next = other.next;
    }
    
    // getters
    string getName()
    {
        return name;
    }

    string getType()
    {
        return type;
    }

    Symbolinfo *getNext()
    {
        return next;
    }

    // setters
    void setName(string name)
    {
        this->name = name;
    }

    void setType(string type)
    {
        this->type = type;
    }

    void setNext(Symbolinfo *next)
    {
        this->next = next;
    }

    /**
     * @brief friend function to print the symbol information
     * e.g. Symbolinfo info("a", "int");
     * cout << info << endl; // prints < a : int > 
     * 
     */
    friend ostream &operator<<(ostream &os, const Symbolinfo &obj)
    {
        os << "< " << obj.name << " : " << obj.type << ">";
        return os;
    }
};