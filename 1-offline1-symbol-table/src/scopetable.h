#pragma once
#include <bits/stdc++.h>
#include "symbolinfo.h"
#include "logger.h"
using namespace std;

/**
 * @brief class implementation of a hash table
 *
 */
class ScopeTable
{
#define tagMsg "ScopeTable::"
    Symbolinfo **table; // array of pointers to Symbolinfo(2d array)
    int total_bukets;   // size of the hash table

    // to mainatain a list of scope tables in the symbol table
    ScopeTable *parentScope;

    // each table has a unique scope id
    // id format: <parent_id>.<current_id>
    // where parent_id is the id of the parent scope
    // and current_id is a serial no. relative to its parent
    // e.g. consider an id 1.3.2 and 8 scope tables were deleted
    // before this level(4th level) after 1.3.2 was created.
    // then the scope id of the 4th level table will be 1.3.2.9
    string id;

    /// child scope counter
    int scopeCount;

    /**
     * @brief hash function to get the hash value of a string
     */
    int calculateHash(string key)
    {
        int idx = sdbmhash(key) % total_bukets;
        // logger2(tag);
        // log(key, idx);
        log(tag(tagMsg), key, idx);
        return idx;
    }

    /**
     * @brief http://www.cse.yorku.ca/~oz/hash.html
     * sdbmhash is a standard string hash function
     */
    unsigned long sdbmhash(string str)
    {
        unsigned long hash = 0;
        for (int i = 0; i < str.length(); i++)
        {
            hash = str[i] + (hash << 6) + (hash << 16) - hash;
        }
        log(tag(tagMsg), str, hash);
        return hash;
    }

public: // public constructor & funtions ===============================
    /// constructor
    ScopeTable(int n, ScopeTable *parentScope)
    {
        scopeCount = 0;   // initialize child scope count to 0
        total_bukets = n; // total slots in the hash table
        table = new Symbolinfo *[total_bukets];
        for (int i = 0; i < total_bukets; i++)
        {
            table[i] = nullptr;
        }

        this->parentScope = parentScope;

        // generate id
        id = "";
        if (parentScope != nullptr)
        {
            parentScope->scopeCount++;
            id = parentScope->id + "." + to_string(parentScope->scopeCount);
        }
        else
        {
            id = "1";
        }
        log(tag(tagMsg), id);
    }

    /// destructor
    ~ScopeTable()
    {
        delete parentScope;
        for (int i = 0; i < total_bukets; i++)
        {
            if (table[i] != nullptr)
            {
                delete table[i];
            }
        }
        delete[] table;
    }

    /// scope table functions

    /**
     * @brief insert into symbol table if already not inserted
     * in this scope table
     *
     * @param name is the name of the symbol
     * @param type is the type of the symbol
     *
     * @return true on successful insertion
     * @return false on failure
     */
    bool insertSymbol(string name, string type)
    {
        log(tag(tagMsg), name, type);
        int idx = calculateHash(name);

        /// case-1: if the symbol is not present in the table
        if (table[idx] == nullptr)
        {
            table[idx] = new Symbolinfo(name, type);
            return true;
        }

        /// case-2: if the symbol is present in the table
        Symbolinfo *temp = table[idx];
        int position = 0;
        // go to the end of the list
        while (temp->getNext() != nullptr)
        {
            if (temp->getName() == name)
            {
                cout << *temp << " already exist in ScopeTable # " << id << endl;
                return false; // symbol already exist
            }
            position++;
            temp = temp->getNext();
        }

        // insert new symbol at the end of the list
        temp->setNext(new Symbolinfo(name, type));
        cout << "Inserted in ScopeTable # " << id << " at position " << idx << ", " << position << endl;

        return true;
    }

    /**
     * @brief search for a symbol in the scope table
     * If 1st calculate the hash value for the index in table.
     * then linear search in the list at that index.
     *
     * @param name is the name of the symbol
     *
     * @return Symbolinfo pointer on successful search
     * @return nullptr on failure
     */
    Symbolinfo *lookUp(string symbolName)
    {
        int idx = calculateHash(symbolName);

        Symbolinfo *temp = table[idx];
        int position = 0;
        while (temp != nullptr)
        {
            if (temp->getName() == symbolName)
            {
                cout << "Found in ScopeTable# " << id << " at position " << idx << ", " << position << endl;
                return temp;
            }
            position++;
            temp = temp->getNext();
        }
        return nullptr;
    }

    /**
     * @brief delete the symbol from the scope table
     *
     * @param name is the name of the symbol
     *
     * @return true on successful deletion
     * @return false on failure
     */
    bool deleteSymbol(string name)
    {
        int idx = calculateHash(name);

        Symbolinfo *temp = table[idx];
        Symbolinfo *prev = nullptr;

        int position = 0; // position of the symbol in the idt th list
        while (temp != nullptr)
        {
            if (temp->getName() == name)
            {
                cout << "Found in ScopeTabl # " << id << " at position " << idx << ", " << position << endl
                     << endl;
                if (prev == nullptr) // first element
                {
                    table[idx] = temp->getNext();
                }
                else
                {
                    prev->setNext(temp->getNext());
                }
                delete temp;
                cout << "Deleted Entry " << idx << ", " << position << " from current ScopeTable" << endl;
                return true; // deleted successfully
            }
            prev = temp;
            position++;
            temp = temp->getNext();
        }

        cout << "Not found" << endl;
        return false;
    }

    /**
     * @brief print the symbol table
     */
    void print()
    {
        cout << "ScopeTable # " << id << endl;
        for (int i = 0; i < total_bukets; i++)
        {
            cout << i << " -->  ";
            Symbolinfo *temp = table[i];
            while (temp != nullptr)
            {
                cout << *temp << "  ";
                temp = temp->getNext();
            }
            cout << endl;
        }
    }
};
