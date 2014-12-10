#include "pugixml.hpp"
#include <ctime>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <boost/filesystem.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/regex.hpp>

using namespace std;
using namespace boost::filesystem;

int traverse_folder(const boost::filesystem::path, vector<std::string>);
int write_data(const boost::filesystem::path, vector<std::string>, ofstream&);
inline string TMCinfo_to_String(const pugi::xml_node);
inline string filename_analysis(const string);
inline bool is_file_exist(const char *);
inline bool is_digits(const std::string &);

extern const boost::regex folder_filter("(\\w*:?\\\\)*RealtimeFlow");
extern const boost::regex escaped_filter("(\\w*:?\\\\)*Incident");
extern const boost::regex data_folder_filter("(\\w*:?\\\\)*RealtimeFlow(\\\\)\\w{2}");
extern const boost::regex gz_filter("(\\w*:?\\\\)*\\w*.gz");


const string Route_info = "ROAD_CODE,";						// reserve information, currently not used
const string Time_info	= "FILE_TIMESTEMP, YEAR, MONTH, DAY, HOUR, MINUTE, SECOND,";
const string TMC_info	= "TIMESTEMP, TMC_ID, LOCATION_ID, LOCATION_DESC, ROAD_DIRECTION, LENGTH(mi), LANE_TYPE, current_DURATION(min), current_AVERAGE_SPEED(mph), freeflow_DURATION(min), freeflow_AVERAGE_SPEED(mph), JAM_FACTOR, JAM_FACTOR_TREND, CONFIDENCE";

int main(int argc, char* argv[])
{
	// # can add argv[] detection (argument 1)
	path root ("D:\\Data_Repository\\TMC_RealtimeFlow");
	// # can add argv[] detection (argument 2)
	std::ifstream inputfile("D:/Project_Programs/QueryTMCdata_ver_1.1 - Fullinfo/target/F4_Route_unique_TMC_list.txt");
	
	if(!inputfile){ //Always test the file open.
		std::cout<<"Error opening output file"<< std::endl;		// DUBUG INFO
		system("pause");
		return -1;
	}

	// section: read TMC list data into vector
	std::string line;
	std::vector<std::string> TMCvector;
	
	while (std::getline(inputfile, line))
		TMCvector.push_back(line);

	// take down the starting time of program
	clock_t begin_time = std::clock();
	// Enter in main program
	traverse_folder(root, TMCvector);
	// calculate the elapsed time
	std::cout << float( std::clock () - begin_time ) /  CLOCKS_PER_SEC << std::endl;
	system("pause");
	return 0;
}

int write_data(const boost::filesystem::path current_dir, vector<std::string> TMCvector, ofstream& Output_file){
	// write header information in to outputfile
	string input_folder = current_dir.string();

	pugi::xml_document doc;

	// traverse the folder to read all .xml files in this folder
	for (recursive_directory_iterator iter(current_dir), end; iter != end; ++iter) {
		std::string gzfile_name = input_folder + '\\' + iter->path().leaf().string();
		int lastindex = gzfile_name.find_last_of(".");
		std::string file_name = gzfile_name.substr(0, lastindex);

		std::string unzip_cmd = "gzip -k -d " + gzfile_name;
		std::cout << "unzipping file: " << gzfile_name << std::endl;
		system(unzip_cmd.data());

		// for each file, read it into memory
		if (!doc.load_file(file_name.data())){
			std::cout<< "Error loading file " << file_name << std::endl;		// DUBUG INFO
			system("pause");
			return -1;
		}
		
		std::string Date_info = filename_analysis(file_name);
		std::vector<std::string>::iterator it;
		// start extracting TMC data from it.
		for ( it = TMCvector.begin(); it<TMCvector.end(); it++){
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
		std::cout << "Finish extracting data from file: " << gzfile_name << std::endl;
	}
	return 0;
}

int traverse_folder(const boost::filesystem::path p, vector<std::string> TMCvector){
	try{
		if (exists(p)){    // does p actually exist?
		  if (is_directory(p)){      // is p a directory?
			cout << p << " is a directory containing:\n";

			vector<path> v;                                // so we can sort them later
			copy(directory_iterator(p), directory_iterator(), back_inserter(v));
			sort(v.begin(), v.end());             // sort, since directory iteration is not ordered on some file systems
			// cicumstance 2: target folder (RealtimeFlow folder)
			if (boost::regex_match(p.string(), folder_filter)){
				clock_t begin_time = std::clock();
				// create a file stream
				// std::cout << "******************************" << endl;		# DEBUG info
				// Opening file to print info to, file name can be modified.
				ofstream Output_file (p.string() + "_test_TMC_output.csv");
				Output_file << Time_info << TMC_info << endl;		// add headline information
				for (vector<path>::const_iterator it(v.begin()), it_end(v.end()); it != it_end; ++it){
					cout << "   " << *it << '\n';
					path current_path = *it;
					std::string delete_cmd = "del " + current_path.string() + "\\*.xml";
					std::cout << "pre processing: deleted unzipped xml files in folder " << current_path.string()  << std::endl;
					system(delete_cmd.data());
					write_data(current_path, TMCvector, Output_file);
					// system("pause");			// DEBUG info
					system(delete_cmd.data());
					std::cout << "after processing: deleted unzipped xml files in folder " << current_path.string()  << std::endl;
				}
				Output_file.close();
			}
			// circumstance 3: the incident folder that need to be escape
			else if (boost::regex_match(p.string(), escaped_filter))
				return 0;
			// circumstance 4: folder but not target folder
			else {
				for (vector<path>::const_iterator it(v.begin()), it_end(v.end()); it != it_end; ++it){
					cout << "   " << *it << '\n';
					traverse_folder(*it, TMCvector);
				}
			}
		  }
		  else
			  ;
			// cout << p << " exists, but is neither a regular file nor a directory\n";
		}
		else
			;
		  // cout << p << " does not exist\n";
	  }
	  catch (const filesystem_error& ex){
		cout << ex.what() << '\n';
	  }
	  return 0;
}

inline bool is_file_exist(const char *fileName){
    std::ifstream infile(fileName);
    return infile.good();
}

inline string filename_analysis(const string filename){
	std::cout << filename << std::endl;		// # DEBUG info
	std::string s = filename;
	std::string delimiter = "_";
	size_t pos = 0;
	std::string token;
	std::string Date_info;
	std::string varFILE_TIMESTEMP;
	int count = 0;	// flag

	while ((pos = s.find(delimiter)) != std::string::npos) {
		token = s.substr(0, pos);
		if (is_digits(token)){
			count++;
			// std::cout << token << std::endl;
			switch (count){
				// FILE_TIMESTEP format YYYY MM DD HH:MM:SS
				case 1:			// YYYY
				case 2:			// MM
				case 3:			// DD
					varFILE_TIMESTEMP = varFILE_TIMESTEMP + token + ' ';		
					Date_info += token + ',';
					break;
				case 4:			// HH
				case 5:			// MM
					varFILE_TIMESTEMP = varFILE_TIMESTEMP + token + ':';		
					Date_info += token + ',';
					break;
				case 6:			// SS
					varFILE_TIMESTEMP = varFILE_TIMESTEMP + token;		
					Date_info += token + ',';
					break;
				case 0:
				default:
					break;
			}		
		}
		s.erase(0, pos + delimiter.length());
	}

	Date_info = varFILE_TIMESTEMP + ',' + Date_info;
	return Date_info;
}

/* Note: this function may need to be modified if mode information need to extracted, or the format of Naveteq data changed. */
inline string TMCinfo_to_String(const pugi::xml_node TMC_node){
	// Column #1 TMC_ID
	string varID			= TMC_node.child_value("ID");
	// std::cout << "1 TMC_ID:\t" << varID << std::endl;
	// Column #2 LOCATION_ID
	string varLOCATION_ID	= TMC_node.child("RDS_LINK").child("LOCATION").child_value("LOCATION_ID");
	// std::cout << "2 LOCATION_ID:\t"<< varLOCATION_ID << std::endl;
	// Column #3 LOCATION_DESC
	string varLOCATION_DESC	= TMC_node.child("RDS_LINK").child("LOCATION").child_value("LOCATION_DESC");
	// std::cout << "3 LOCATION_DESC:\t"<< varLOCATION_DESC << std::endl;
	// Column #4 ROAD_DIRECTION
	string varROAD_DIRECTION	= TMC_node.child("RDS_LINK").child("LOCATION").child_value("RDS_DIRECTION");
	// varROAD_DIRECTION = ("+" == varROAD_DIRECTION) ? 1 : -1;			// translate "+" / "-" to "1" "-1"
	// std::cout << "4 ROAD_DIRECTION:\t"<< varROAD_DIRECTION << std::endl;
	// Column #5 LENGTH
	string varLENGTH	= TMC_node.child("RDS_LINK").child_value("LENGTH");
	// std::cout << "5 LENGTH:\t"<< varLENGTH << std::endl;
	// Column #6 LANE_TYPE
	string varLANE_TYPE	= TMC_node.child("CURRENT_FLOW").child("TRAVEL_TIMES").child("LANE_TYPE").attribute("TYPE").value();
	//std::cout << "6 LANE_TYPE:\t"<< varLANE_TYPE << std::endl;
	// Column #7 current_DURATION
	string var_current_DURATION	= TMC_node.child("CURRENT_FLOW").child("TRAVEL_TIMES").child("LANE_TYPE").first_child().child_value("DURATION");
	// std::cout << "7 current_DURATION:\t"<< var_current_DURATION << std::endl;
	// Column #8 current_AVERAGE_SPEED
	string var_current_AVERAGE_SPEED	= TMC_node.child("CURRENT_FLOW").child("TRAVEL_TIMES").child("LANE_TYPE").first_child().child_value("AVERAGE_SPEED");
	// std::cout << "8 current_AVERAGE:\t"<< var_current_AVERAGE_SPEED << std::endl;
	// Column #9 freeflow_DURATION
	string var_freeflow_DURATION	= TMC_node.child("CURRENT_FLOW").child("TRAVEL_TIMES").child("LANE_TYPE").first_child().next_sibling().child_value("DURATION");
	//std::cout << "9 freeflow_DURATION:\t"<< var_freeflow_DURATION << std::endl;
	// Column #10 freeflow_AVERAGE_SPEED
	string var_freeflow_AVERAGE_SPEED	= TMC_node.child("CURRENT_FLOW").child("TRAVEL_TIMES").child("LANE_TYPE").first_child().next_sibling().child_value("AVERAGE_SPEED");
	// std::cout << "10 freeflow_AVERAGE:\t"<< var_freeflow_AVERAGE_SPEED << std::endl;
	// Column #11 JAM_FACTOR
	string varJAM_FACTOR	= TMC_node.child("CURRENT_FLOW").child_value("JAM_FACTOR");
	// std::cout << "11 JAM_FACTOR:\t"<< varJAM_FACTOR << std::endl;
	// Column #12 JAM_FACTOR_TREND
	string varJAM_FACTOR_TREND	= TMC_node.child("CURRENT_FLOW").child_value("JAM_FACTOR_TREND");
	// std::cout << "12 JAM_FACTOR_TREND:\t"<< varJAM_FACTOR_TREND << std::endl;
	// Column #13 CONFIDENCE
	string varCONFIDENCE	= TMC_node.child("CURRENT_FLOW").child_value("CONFIDENCE");
	// std::cout << "13 CONFIDENCE:\t"<< varCONFIDENCE << std::endl;

	string TMC_record = varID + ',' + varLOCATION_ID + ',' + varLOCATION_DESC + ',' + varROAD_DIRECTION + ',' + varLENGTH + ',' + varLANE_TYPE + ',' + var_current_DURATION + ',' + var_current_AVERAGE_SPEED + ',' + var_freeflow_DURATION + ',' + var_freeflow_AVERAGE_SPEED + ',' + varJAM_FACTOR + ',' + varJAM_FACTOR_TREND + ',' + varCONFIDENCE;

	return TMC_record;
}

bool is_digits(const std::string &str)
{
    return std::all_of(str.begin(), str.end(), ::isdigit); // C++11
}