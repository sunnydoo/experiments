
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

#include "sdTest.h";
#include "sdTestConfig.h";

using namespace cv;
using namespace std;

void sdShowVideo()
{
	namedWindow("Show Video", CV_WINDOW_AUTOSIZE );
	CvCapture* capture = cvCreateFileCapture( videoPath() );

	IplImage* frame;
	while(1) {
		frame = cvQueryFrame( capture );
		if( !frame ) break;
		cvShowImage( "Show Video", frame );
		char c = cvWaitKey(10);

		if( c== 27 ) break;
	}

	cvReleaseCapture( &capture );
	cvDestroyWindow( "Show Video" );
}

//isolate the global variables to this file
//static int g_slider_position = 0;
static CvCapture* g_capture  = NULL;

void onTrackBarSlide( int pos ) 
{
	cvSetCaptureProperty(g_capture, CV_CAP_PROP_POS_FRAMES, pos);
	//g_slider_position = pos;
}

void sdControlVideo()
{
	namedWindow( "Show Video", CV_WINDOW_AUTOSIZE );
	g_capture = cvCreateFileCapture( videoPath() );

	int frames = (int)cvGetCaptureProperty( g_capture, CV_CAP_PROP_FRAME_COUNT );

	int pos = frames/2;
	if( frames != 0 )
	{
		cvCreateTrackbar("Video Position", "Show Video", &pos, frames, onTrackBarSlide );
	}

	IplImage* frame;

	while(1) {
		frame = cvQueryFrame( g_capture );
		if( !frame ) break;
		cvShowImage( "Show Video", frame );

		int pos2 = cvGetCaptureProperty( g_capture, CV_CAP_PROP_POS_FRAMES );
		cvSetTrackbarPos( "Video Position", "Show Video", pos2 );

		cout << "Position:" << pos << endl;
		char c = cvWaitKey(10);

		if( c== 27 ) break;
	}

	cvReleaseCapture( &g_capture );
	cvDestroyWindow( "Show Video" );
}


void sdCompareVideo()
{
	namedWindow("Original Video");
	namedWindow("Processed Video");

	CvCapture* capture = cvCreateFileCapture( videoPath() );

	IplImage* frame = cvQueryFrame( capture );
	IplImage* out = cvCreateImage( cvGetSize(frame), IPL_DEPTH_8U, 3 );

	while(1) {
		frame = cvQueryFrame( capture );
		if( !frame ) break;
		cvShowImage( "Original Video", frame );
		
//CV_BLUR_NO_SCALE =0,
//CV_BLUR  =1,
//CV_GAUSSIAN  =2,
//CV_MEDIAN =3,
//CV_BILATERAL =4


		cvSmooth( frame, out,  CV_MEDIAN, 3, 3);
		//cvPyrDown( frame, out );
		cvShowImage( "Processed Video", out );

		char c = cvWaitKey(10);

		if( c== 27 ) break;
	}

	cvReleaseImage( &out );

	cvDestroyWindow( "Original Video");
	cvDestroyWindow( "Processed Video" );
}