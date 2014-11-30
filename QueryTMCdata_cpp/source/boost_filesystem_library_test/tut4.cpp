//  filesystem tut4.cpp  ---------------------------------------------------------------//

//  Copyright Beman Dawes 2009

//  Distributed under the Boost Software License, Version 1.0.
//  See http://www.boost.org/LICENSE_1_0.txt

//  Library home page: http://www.boost.org/libs/filesystem

#include <iostream>
#include <iterator>
#include <vector>
#include <algorithm>
#include <boost/filesystem.hpp>
#include <ctime>
#include<boost\regex.hpp>

using namespace std;
using namespace boost::filesystem;

extern const boost::regex folder_filter("(\\w*:?\\\\)*RealtimeFlow");
extern const boost::regex xml_filter("(\\w*:?\\\\)*\\w*.xml");

void traverse_folder(const boost::filesystem::path);

int main(int argc, char* argv[])
{
  path root ("D:\\Dataset");
  const clock_t begin_time = std::clock();
  traverse_folder(root);
  std::cout << float( std::clock () - begin_time ) /  CLOCKS_PER_SEC << std::endl;		// calculate the elapsed time
  system("pause");
  return 0;
}

void traverse_folder(const boost::filesystem::path p){
	try{
		if (exists(p)){    // does p actually exist?
		  if (is_regular_file(p) && boost::regex_match(p.string(), xml_filter))        // is p a regular file?
			  // do something
			cout << p << " This is an xml file: " << file_size(p) << '\n';

		  else if (is_directory(p)){      // is p a directory?
			std::cout << p.string() << std::endl;
			if (boost::regex_match(p.string(), folder_filter))
				// do something
				std::cout << "******************************" << endl;
			
			cout << p << " is a directory containing:\n";

			vector<path> v;                                // so we can sort them later

			copy(directory_iterator(p), directory_iterator(), back_inserter(v));

			sort(v.begin(), v.end());             // sort, since directory iteration
												  // is not ordered on some file systems
			for (vector<path>::const_iterator it(v.begin()), it_end(v.end()); it != it_end; ++it){
				cout << "   " << *it << '\n';
				traverse_folder(*it);
			}
		  }
		  else
			cout << p << " exists, but is neither a regular file nor a directory\n";
		}
		else
		  cout << p << " does not exist\n";
	  }
	  catch (const filesystem_error& ex){
		cout << ex.what() << '\n';
	  }
}

















	ofstream Output_file ("test_TMC_output.csv");			// Opening file to print info to
	
	
	// write header information in to outputfile
	Output_file << Time_info << TMC_info << endl;

	// take down the starting time of program
	const clock_t begin_time = std::clock();	

	string input_folder = "D:/Dataset/201109/RealtimeFlow/01";
	path current_dir(input_folder.data());		// .data() transfer string into char*
	pugi::xml_document doc;

	std::ifstream inputfile("./target/F3_Route_unique_TMC_list.txt");
	if(!inputfile){ //Always test the file open.
		std::cout<<"Error opening output file"<< std::endl;		// DUBUG INFO
		system("pause");
		return -1;
	}

	// section: read TMC list data into vector
	std::string line;
	std::vector<std::string> TMCvector;
	std::vector<std::string>::iterator it;

	while (std::getline(inputfile, line))
		TMCvector.push_back(line);

	// traverse the folder to read all .xml files in this folder
	for (recursive_directory_iterator iter(current_dir), end; iter != end; ++iter) {
		std::string file_name = input_folder + '/' + iter->path().leaf().string();

		// for each file, read it into memory
		if (!doc.load_file(file_name.data())){
			std::cout<< "Error loading file " << file_name << std::endl;		// DUBUG INFO
			std::cout << float( std::clock () - begin_time ) /  CLOCKS_PER_SEC << std::endl;		// calculate the elapsed time
			system("pause");
			return -1;
		}
		
		std::string Date_info = filename_analysis(file_name);

		// start extracting TMC data from it.
		for (it = TMCvector.begin(); it<TMCvector.end(); it++){
			// for each TMC code, do the following step:
			string varTIEMSTEMP = doc.child("TRAFFICML_REALTIME").attribute("TIMESTAMP").value();
			// Query the xml file to find the nodes of target TMC section
			string XPath_query_string = "/TRAFFICML_REALTIME/ROADWAY_FLOW_ITEMS/ROADWAY_FLOW_ITEM/FLOW_ITEMS/FLOW_ITEM[ID='" + *it +  "']";
			pugi::xpath_query query_remote_tools(XPath_query_string.data());
			pugi::xpath_node_set TMCsets = query_remote_tools.evaluate_node_set(doc);

			// all found nodes are in teh node_set, then put the information of the node in to string and write into outfile.
			pugi::xml_node TMC_node = TMCsets[0].node();
			string TMC_record = TMCinfo_to_String(TMC_node);
			Output_file << Date_info << varTIEMSTEMP << ',' << TMC_record << std::endl;
		}
	}
	Output_file.close();
	std::cout << float( std::clock () - begin_time ) /  CLOCKS_PER_SEC << std::endl;		// calculate the elapsed time
	system("pause");