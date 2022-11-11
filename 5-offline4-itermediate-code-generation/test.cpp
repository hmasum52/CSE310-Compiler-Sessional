#include<bits/stdc++.h>
using namespace std;

int main(){
    // filestream seek example
    ofstream file;
    file.open("test.txt",ios::out);
    if(!file){
        cout<<"error opening file"<<endl;
    }
    file << "Hello world"<<endl;
    file.close();
    file.open("test.txt", ios::app);
    file.seekp(0, ios::beg);
    file<< ".MODEL SMALL"<<endl;
   // cout<<"balsal"<<endl;
    
    file.close();
}