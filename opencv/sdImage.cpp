
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

#include "sdTest.h";
#include "sdTestConfig.h";

using namespace cv;
using namespace std;

void sdShowImage()
{
	Mat image;
    image = imread(imgPath(), IMREAD_COLOR); // Read the file

    if(! image.data ) // Check for invalid input
    {
        cout << "Could not open or find the image" << std::endl ;
        return;
    }

    namedWindow( "Display window", WINDOW_AUTOSIZE ); // Create a window for display.
    imshow( "Display window", image ); // Show our image inside it.
	return;
}
