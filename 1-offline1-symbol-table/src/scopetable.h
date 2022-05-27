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
    const string tagMsg = "ScopeTable::"; // for debugging

    Symbolinfo **table; // array of pointers to Symbolinfo(2d array)
    int tableSize;   // size of the hash table

    // to mainatain a list of scope tables in the symbol table
    ScopeTable *parentScopeTable;

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
        int idx = sdbmhash(key) % tableSize;
        //log(tag(tagMsg), key, idx);
        return idx;
    }

    /**
     * @brief http://www.cse.yorku.ca/~oz/hash.html
     * sdbmhash is a standard string hash function
     */
    uint32_t sdbmhash(string str)
    {
        uint32_t hash = 0;
        //int hash = 0;
        for (int i = 0; i < str.length(); i++)
        {
            hash = str[i] + (hash << 6) + (hash << 16) - hash;
        }
        // log(tag(tagMsg), str, hash);
        return hash;
    }

public: // public constructor & funtions ===============================
    /// constructor
    ScopeTable(int n, ScopeTable *parentScopeTable)
    {
        scopeCount = 0;                         // initialize child scope count to 0
        tableSize = n;                       // total slots in the hash table
        table = new Symbolinfo *[tableSize]; // allocate memory for the hash table

        // init each slot to nullptr
        for (int i = 0; i < tableSize; i++)
        {
            table[i] = nullptr;
        }

        this->parentScopeTable = parentScopeTable;

        // generate id
        id = "";
        if (parentScopeTable != nullptr)
        {
            parentScopeTable->scopeCount++;
            id = parentScopeTable->id + "." + to_string(parentScopeTable->scopeCount);
            cout << "New ScopeTable with id "<<id<<" created"<<endl<<endl;
        }
        else
        {
            id = "1"; // for 1st level scope table
        }
        //log(tag(tagMsg), id, tableSize);
    }

    void resursiveFree(Symbolinfo *symbol)
    {
        if (symbol == nullptr)
            return;
        resursiveFree(symbol->getNext());
        delete symbol;
    }

    /// destructor
    ~ScopeTable()
    {
        // as table elements are pointers, we need to delete them individually
        for (int i = 0; i < tableSize; i++)
        {
            if(table[i]!=nullptr){
                Symbolinfo *symbol = table[i];
                while(symbol!=nullptr){
                    Symbolinfo *temp = symbol;
                    symbol = symbol->getNext();
                    delete temp;
                }
            }
        }

        // finally delete the table pointer
        delete[] table;

        //delete parentScopeTable;
        //log(tag(tagMsg), "freed resources");
    }

    /// getter and setters
    ScopeTable *getParentScopeTable()
    {
        //log(tag(tagMsg), parentScopeTable);
        return parentScopeTable;
    }

    string getId()
    {
        return id;
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
        cout<<"Inserting "<<name<<" in scope "<<id<<endl;
        // log(tag(tagMsg), name, type);
        int idx = calculateHash(name);

        /// case-1: if the symbol is not present in the table
        if (table[idx] == nullptr) // curr == nullptr
        {
            table[idx] = new Symbolinfo(name, type);
            //log(tag(tagMsg), table[idx], idx);
            cout << "Inserted in ScopeTable # " << id << " at position " << idx << ", " << 0 << endl << endl;
            return true;
        }

        /// case-2: if the symbol is present in the table
        Symbolinfo *curr = table[idx];
        Symbolinfo *prev = nullptr;
        int position = 1;
        // go to the end of the list
        while (curr != nullptr)
        {
            //log(tag(tagMsg), curr, idx, position);
            if (curr->getName() == name)
            {
                cout << *curr << " already exists in current ScopeTable" <<endl
                     << endl;
                return false; // symbol already exist
            }
            position++;
            prev = curr;
            curr = curr->getNext();
        } 

        // insert new symbol at the end of the list
        prev->setNext(new Symbolinfo(name, type));
        cout << "Inserted in ScopeTable # " << id << " at position " << idx << ", " << position << endl << endl;

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
    Symbolinfo *lookupSymbol(string symbolName)
    {
        int idx = calculateHash(symbolName);

        Symbolinfo *temp = table[idx];
        int position = 0;
        while (temp != nullptr)
        {
            if (temp->getName() == symbolName)
            {
                cout << "Found in ScopeTable# " << id << " at position " << idx << ", " << position << endl << endl;
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

        Symbolinfo *curr = table[idx];
        Symbolinfo *prev = nullptr;

        int position = 0; // position of the symbol in the idt th list
        while (curr != nullptr)
        {
            if (curr->getName() == name)
            {
                cout << "Found in ScopeTable # " << id << " at position " << idx << ", " << position << endl
                     << endl;
                if (prev == nullptr) // first element
                {
                    table[idx] = curr->getNext();
                }
                else
                {
                    prev->setNext(curr->getNext());
                }
                delete curr; // free memory
                cout << "Deleted Entry " << idx << ", " << position << " from current ScopeTable" << endl << endl;
                return true; // deleted successfully
            }
            prev = curr;
            position++;
            curr = curr->getNext();
        }

        cout << "Not found" << endl<<endl;
        return false;
    }

    /**
     * @brief print the symbol table
     */
    void print()
    {
        cout << "ScopeTable # " << id << endl;
        for (int i = 0; i < tableSize; i++)
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
        cout << endl;
    }
};
