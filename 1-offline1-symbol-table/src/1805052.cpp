#include <bits/stdc++.h>
#include "symbolinfo.h"
using namespace std;
/**
 * @brief class implementation of a hash table
 *
 */
class ScopeTable
{
    Symbolinfo **table; // array of pointers to Symbolinfo
    int total_bukets; // size of the hash table

    // to mainatain a list of scope tables in the symbol table
    ScopeTable * parentScope;

    // each table has a unique scope id
    // id format: <parent_id>.<current_id>
    // where parent_id is the id of the parent scope
    // and current_id is a serial no. relative to its parent
    // e.g. consider an id 1.3.2 and 8 scope tables were deleted
    // before this level(4th level) after 1.3.2 was created.
    // then the scope id of the 4th level table will be 1.3.2.9
    string id;

    /**
     * @brief hash function to get the hash value of a string
     */
    int calculateHash(string key)
    {
        return sdbmhash(key) % total_bukets;
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
        return hash;
    }

public: // public constructor & funtions ===============================

    /// constructor
    ScopeTable(int n){

    }

    /// destructor
    ~ScopeTable(){

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
    bool insertSymbol(string name, string type){
        int idx = calculateHash(name);

        return false;
    }

    Symbolinfo* lookUp(string symbolName){
        int idx = calculateHash(symbolName);
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
    bool deleteSymbol(string name){
        int idx = calculateHash(name);
        return false;
    }

    /**
     * @brief print the symbol table
     */
    void print(){
        for(int i = 0; i < total_bukets; i++){
            Symbolinfo *temp = table[i];
            while(temp != nullptr){
                cout << *temp << endl;
                temp = temp->getNext();
            }
        }
    }
};

int main()
{
    Symbolinfo info("a", "int");
    cout << info << endl;
}
