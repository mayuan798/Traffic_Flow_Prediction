#include <boost/regex.hpp>
#include <iostream>
 
using namespace std;
 
//( 1 )   ((  3  )  2 )((  5 )4)(    6    )
//(/w+)://((/w+/.)*/w+)((//w*)*)(//w+/./w+)?
//^协议://网址(x.x...x)/路径(n个/字串)/网页文件(xxx.xxx)
const char *str_reg="(\\w+)://((\\w+\\.)*\\w+)((/\\w*)*)(/\\w+\\.\\w+)?";
const char *str_orig="http://www.allen2660.com/2013/03/10/newcomputer.html";
 
//1. 首先是regex_match函数，此处简单的判断是否匹配
//boost::regex的构造函数中还可以加入标记参数用于指定它的行为，如:
//指定使用perl语法（默认），忽略大小写。
//boost::regex reg1( szReg, boost::regex::perl|boost::regex::icase );
//指定使用POSIX扩展语法（其实也差不多）
//boost::regex reg2( szReg, boost::regex::extended );
void test_match(){
    boost::regex reg( str_reg );
    bool r =boost::regex_match(str_orig, reg );
    cout<<r<<endl;
}
 
//2. 从匹配中提取结果
//其中，boost::cmatch是一个针对C字符串的特化版本，它还有另三位兄弟,如下:
//typedef match_results<const char*> cmatch;typedef match_results<std::string::const_iterator> smatch;typedef match_results<const wchar_t*> wcmatch;typedef match_results<std::wstring::const_iterator> wsmatch;
//可以把match_results看成是一个sub_match的容器，同时它还提供了format方法来代替regex_format函数。
//一个sub_match就是一个子串，它从std::pair<BidiIterator, BidiIterator>继承而来，这个迭代器pair里的first和second分别指向了这个子串开始和结尾所在位置。同时，sub_match又提供了str()，length()方法来返回整个子串。
void test_cmatch(){
    //cmatch是针对c字符串的一个特化版本
    boost::cmatch mat;
    boost::regex reg( str_reg);
    //这个regex_match函数多了一个参数
    bool r = boost::regex_match( str_orig, mat , reg);
    if(r){
        cout<< "mat size is "<< mat.size()<<endl;
        typedef boost::cmatch::iterator match_itr;
        match_itr itr = mat.begin();
        while(itr!=mat.end()){
            //itr的first和second指向匹配字符串的首位位置
            //cout<< itr->first << ' '<<itr->second << ' '<< *itr<<endl;
            cout<<  *itr<<endl;
            itr++;
        }
    }
 
    //也可以直接取指定位置的信息
    if(mat[4].matched){
        cout<< "Path is " << mat[4] <<endl;
    }
}
 
//3. 查找字符串
void test_search(){
    boost::cmatch mat;
    boost::regex reg( "\\d+");
    if(boost::regex_search(str_orig, mat ,reg)){
        cout<< "Searchd:"<< mat[0] <<endl;
        cout<< "Size is "<<mat.size()<<endl;
    }
}
 
//4. 替换字符串
void test_replace(){
    boost::regex reg(str_reg);
    //正则表达式中，使用$1~$9（或/1~/9）表示第几个子串,
    //$&表示整个串，$`表示第一个串,$'表示最后未处理的串
    string s = boost::regex_replace( string(str_orig),reg,"ftp://$2$5");
    cout <<"ftp site:"<<s <<endl;
 
    //正则表达式中，使用(?1~?9新字串)表示把第几个子串替换成新字串
    //使用format_all参数把<>&全部转换成网页字符
    string s1 = "(<)|(>)|(&)";
    string s2 = "(?1&lt;)(?2&gt;)(?3&amp;)";
    boost::regex reg1( s1);
    s =
        boost::regex_replace( string("cout<<a&b<<endl;"),reg1,s2,boost::match_default|boost::format_all);
    cout<<"HTML:"<<s<<endl;
}
 
//5. 使用regex_iterator 查找
//对应于C字符串和C++字符串以及宽字符，regex_iterator同样也有四个特化:
//typedef regex_iterator<const char*> cregex_iterator;    typedef regex_iterator<std::string::const_iterator> sregex_iterator;    typedef regex_iterator<const wchar_t*> wcregex_iterator;    typedef regex_iterator<std::wstring::const_iterator> wsregex_iterator;
void test_regex_iterator(){
    //使用迭代器找出所有数字
    boost::regex reg("\\d+");
    //Boost.Regex也提供了make_regex_iterator函数简化regex_iterator的构造，如上面的itrBegin可以写成:
    //itrBegin = make_regex_iterator(szStr,reg);
    boost::cregex_iterator itr_begin( str_orig,
                                str_orig+strlen(str_orig),
                                reg
                              );
    boost::cregex_iterator itr_end;
    boost::cregex_iterator itr = itr_begin;
    while(itr!=itr_end){
        //这个迭代器的value_type是一个match_results。
        cout<<(*itr)[0].first<<' '<<(*itr)[0].second<<" "<<*itr<<endl;
        itr++;
    }
}
 
//6. 使用regex_token_iterator拆分字符串
void test_regex_token_iterator(){
    boost::regex reg("/");//拆分符为/
    //最后的那个参数-1表示以reg为分隔标志拆分字符串
    //Boost.Regex也提供了make_regex_token_iterator函数简化regex_token_iterator的构造
    boost::cregex_token_iterator itrBegins( str_orig,str_orig+strlen(str_orig),reg,-1);
    boost::cregex_token_iterator itr_end;
    boost::cregex_token_iterator itr=itrBegins;
    while(itr!=itr_end){
        //这里的value_type为sub_match
        cout<<*itr<<endl;
        itr++;
    }
 
    //取/的前一字符和后一字符
    reg=boost::regex("(.)/(.)");
    int subs[] = {1,2}; //第一子串和第二子串
    //使用-1参数时拆分，使用其它数字时表示取第几个子串，可使用数组取多个串
    itrBegins=make_regex_token_iterator(str_orig,reg,subs);
    itr=itrBegins;
    while(itr!=itr_end){
        //这里的value_type为sub_match
        cout<<*itr<<endl;
        itr++;
    }
 
}
 
int main(){
    cout<<"====test_regex_match=================================="<<endl;
    test_match();
    cout<<"====test_regex_cmatch================================="<<endl;
    test_cmatch();
    cout<<"====test_regex_search================================="<<endl;
    test_search();
    cout<<"====test_regex_replace================================"<<endl;
    test_replace();
    cout<<"====test_regex_iterator==============================="<<endl;
    test_regex_iterator();
    cout<<"====test_regex_token_iterator========================="<<endl;
    test_regex_token_iterator();
	system("pause");
}