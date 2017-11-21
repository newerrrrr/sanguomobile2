#include "asynchronousBox_Win32.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32

HWND * s_pHWnd = NULL;

asynchronousBox_Win32::asynchronousBox_Win32()
{

}

asynchronousBox_Win32::~asynchronousBox_Win32()
{

}

static HDC S_buffHDC = 0;
static int S_Index = 0;
static HFONT S_Font = 0;
static HBITMAP S_Bitmap = 0;
static HBRUSH S_Brush = 0;
static std::string S_ShowString[4]={"Loading","Loading.","Loading..","Loading..."};
static LRESULT CALLBACK LHSWindowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	PAINTSTRUCT ps;
	HDC hdc;
	switch (message)
	{
	case WM_CREATE:
		{
			hdc=GetDC(hWnd);
			S_buffHDC=CreateCompatibleDC(hdc);
			RECT rect;
			GetClientRect(hWnd,&rect);
			S_Bitmap = CreateCompatibleBitmap(hdc,rect.right,rect.bottom);
			SelectObject(S_buffHDC,S_Bitmap);
			S_Font=CreateFont(20,10,0,0,10,0,0,0,GB2312_CHARSET,0,0,0,0,L"ºÚÌå");
			S_Brush=CreateSolidBrush(RGB(0,0,0));
			SetTimer(hWnd,0,300,NULL);
			ReleaseDC(hWnd,hdc);
		}
		break;
	case WM_TIMER:
		{
			++S_Index;
			InvalidateRect(hWnd,NULL,false);
		}
		break;
	case WM_PAINT:
		{
			hdc = BeginPaint(hWnd, &ps);
			RECT rect;
			GetClientRect(hWnd,&rect);
			SelectObject(S_buffHDC,S_Brush);
			Rectangle(S_buffHDC,rect.left,rect.top,rect.right,rect.bottom);
			SelectObject(S_buffHDC,S_Font);
			SetBkMode(S_buffHDC,TRANSPARENT);
			SetTextColor(S_buffHDC,RGB(255,255,255));
			SetTextAlign(S_buffHDC,TA_CENTER);
			TextOutA(S_buffHDC,rect.left + rect.right / 2 , rect.top + rect.bottom / 2 - 10, S_ShowString[S_Index%4].c_str(), strlen(S_ShowString[S_Index%4].c_str()));
			BitBlt(hdc,rect.left,rect.top,rect.right,rect.bottom,S_buffHDC,0,0,SRCCOPY);
			EndPaint(hWnd, &ps);
		}
		break;
	case WM_DESTROY:
		if (s_pHWnd)
		{
			DeleteObject(S_Font);S_Font = 0;
			DeleteObject(S_Bitmap);S_Bitmap = 0;
			DeleteObject(S_Brush);S_Brush = 0;
			ReleaseDC(hWnd,S_buffHDC);S_buffHDC = 0;
			delete s_pHWnd;
			s_pHWnd = NULL;
		}
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

void asynchronousBox_Win32::showAsynchronousBox()
{
	if (s_pHWnd)
		return;

	const wchar_t * classname = L"Loading";

	WNDCLASS ck;
	ck.cbClsExtra=0;
	ck.cbWndExtra=0;
	ck.hbrBackground=NULL;
	ck.hCursor=NULL;
	ck.hIcon=NULL;
	ck.hInstance=GetModuleHandle(NULL);
	ck.lpfnWndProc=(WNDPROC)LHSWindowProc;
	ck.lpszClassName=classname;
	ck.lpszMenuName=NULL;
	ck.style=0;

	RegisterClass(&ck);

	int width = GetSystemMetrics ( SM_CXSCREEN );
	int height= GetSystemMetrics ( SM_CYSCREEN );
	int w = 100;
	int h = 146;
	s_pHWnd = new HWND;
	*s_pHWnd = CreateWindowEx(WS_EX_TOPMOST, classname, L"Loading...", WS_DLGFRAME, width / 2 - w / 2, height / 2 - h / 2, w, h, NULL, NULL, GetModuleHandle(NULL), NULL);
	ShowWindow(*s_pHWnd, SW_SHOW);
}

void asynchronousBox_Win32::hideAsynchronousBox()
{
	if (s_pHWnd)
		DestroyWindow(*s_pHWnd);
}


#endif