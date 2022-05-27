#include <iostream>
#include <fstream>
#include <string>

int main()
{
	std::string binLine;
	std::ifstream binStream ("challenge.bin");
	if (binStream.is_open())
	{
		while (getline(binStream, binLine))
		{
			std::cout << binLine << "\n";
		}
		binStream.close();
	} else {
		std::cout << "Could not open file!" << "\n";
	}

    return 0;
}

