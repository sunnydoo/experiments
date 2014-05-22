#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

using namespace cv;
using namespace std;



#include "sdTest.h"

int main( int argc, char** argv )
{
	//sdShowImage();
	sdCompareVideo();

    waitKey(0); // Wait for a keystroke in the window
    return 0;
}