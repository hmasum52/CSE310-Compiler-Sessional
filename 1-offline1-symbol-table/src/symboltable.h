#pragma once
#include<bits/stdc++.h>
#include "scopetable.h"
using namespace std;

/**
 * @brief This class implements a list of scope tables.
 * This class is also a list implementation of stack.
 *
 */
class SymbolTable
{
    const string tagMsg = "SymbolTable::";

    // list of scope tables
    // this list mimics the stack of scope tables
    // the top of the list is the current scope table
    // push(insert) and pop(delete) are implemented using this list
    ScopeTable *currentScopeTable;
    int scopeTableSize;

public:
    SymbolTable(int scopeTableSize)
    {
        this->scopeTableSize = scopeTableSize;
        currentScopeTable = new ScopeTable(scopeTableSize, nullptr);
    }

    ~SymbolTable()
    {
        // delete currentScopeTable;
        //  pop all the scope tables
        //  and free resources
        ScopeTable *temp = currentScopeTable;
        while (temp != nullptr)
        {
            currentScopeTable = currentScopeTable->getParentScopeTable();
            delete temp;
            temp = currentScopeTable;
        }
    }

    /**
     * @brief Create a new ScopeTable and make it current one.
     * Also make the previous current table as its parentScopeTable.
     *
     */
    void enterScope()
    {
        currentScopeTable = new ScopeTable(scopeTableSize, currentScopeTable);
    }

    /**
     * @brief Remove the current ScopeTable.
     * Also make the parentScopeTable as currentScopeTable.
     *
     */
    void exitScope()
    {
        if (currentScopeTable == nullptr)
        {
            cout << "NO CURRENT SCOPE" << endl
                 << endl;
            return;
        }

        ScopeTable *temp = currentScopeTable;
        currentScopeTable = currentScopeTable->getParentScopeTable();
        cout << "ScopeTable with id " << temp->getId() << " removed" << endl
             << endl;

        delete temp; // free the memory
    }

    /**
     * @brief Insert a symbol in current ScopeTable
     *
     * @param name is the name of the symbol
     * @param type is the type of the symbol
     * @return true for successful isnertion
     * @return false otherwise
     */
    bool insert(string name, string type)
    {
        // log(tag(tagMsg), name, type);
        if (currentScopeTable == nullptr)
        {
            currentScopeTable = new ScopeTable(scopeTableSize, nullptr);
        }

        return currentScopeTable->insertSymbol(name, type);
    }

    /**
     * @brief Remove a symbol from current ScopeTable.
     *
     * @param name is the name of the symbol to be removed
     * @return true on successful removal
     * @return false otherwise
     */
    bool remove(string name)
    {
        if (currentScopeTable == nullptr)
        {
            return false;
        }

        return currentScopeTable->deleteSymbol(name);
    }

    /**
     * @brief Look up a symbol in the ScopeTable. At first search in the
     * current ScopeTable, if not found then search in the parent ScopeTable and so on
     *
     * @return a pointer to the SymbolInfo object representing the searched symbol.
     * return nullptr if not found.
     */
    Symbolinfo *lookup(string symbolName)
    {
        if (currentScopeTable == nullptr)
        {
            return nullptr;
        }

        // search in current ScopeTable first
        Symbolinfo *symbolInfo = currentScopeTable->lookupSymbol(symbolName);

        // if not found in current ScopeTable, search in parent ScopeTable
        if (symbolInfo == nullptr)
        {
            ScopeTable *parent = currentScopeTable->getParentScopeTable();
            while (parent != nullptr)
            {
                symbolInfo = parent->lookupSymbol(symbolName);
                if (symbolInfo != nullptr)
                {
                    break;
                }
                parent = parent->getParentScopeTable();
            }
        }

        if (symbolInfo == nullptr)
            cout << "Not found" << endl
                 << endl;

        return symbolInfo;
    }

    /**
     * @brief Print the current ScopeTable.
     *
     */
    void printCurrentScopeTable()
    {
        if (currentScopeTable == nullptr)
        {
            return;
        }

        currentScopeTable->print();
    }

    /**
     * @brief Print the entire ScopeTable.
     *
     */
    void printAllScopeTables()
    {
        ScopeTable *scopeTable = currentScopeTable;
        while (scopeTable != nullptr)
        {
            scopeTable->print();
            cout << endl;
            scopeTable = scopeTable->getParentScopeTable();
        }
    }
};
