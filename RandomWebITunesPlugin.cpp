//#include <windows.h>
#include <string>

//#include <GL/gl.h>
//#include <GL/glu.h>
//#include <GL/glext.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>
//#include <GL/wglext.h>

using namespace std;

#include <iTunesVisualAPI.h>

// window information
//HWND windowHandle;
//HDC windowDC;
//HGLRC windowRC;
int windowWidth;
int windowHeight;

// iTunes information
RenderVisualData renderData;
bool playing;

// create OpenGL rendering context for the specified window
/**
void InitializeGL(HWND hwnd)
{
    windowHandle = hwnd;
    windowDC = GetDC(windowHandle);

    PIXELFORMATDESCRIPTOR pfd;
    memset(&pfd, 0, sizeof(PIXELFORMATDESCRIPTOR));

    pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 16;
    pfd.cDepthBits = 16;

    int pixelFormat = ChoosePixelFormat(windowDC, &pfd);
    if (pixelFormat == 0)
        return;

    if (SetPixelFormat(windowDC, pixelFormat, &pfd) == 0)
        return;

    windowRC = wglCreateContext(windowDC);
    if (windowRC == NULL)
        return;

    if (!wglMakeCurrent(windowDC, windowRC))
        return;

    // enable v-sync if WGL_EXT_swap_control is supported
    PFNWGLSWAPINTERVALEXTPROC wglSwapIntervalEXT = NULL;
    wglSwapIntervalEXT = (PFNWGLSWAPINTERVALEXTPROC)wglGetProcAddress("wglSwapIntervalEXT");
    if (wglSwapIntervalEXT != NULL)
        wglSwapIntervalEXT(1);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

// render visualization data
void RenderGL()
{
    if (windowDC == NULL) return;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glScalef((float)windowWidth/512.0f, (float)windowHeight/255.0f, 1.0f);

    glBegin(GL_QUADS);
    for (int i = 0; i < 512; i++)
    {
        int height = renderData.waveformData[1][i];
        int nextHeight;
        if (i < 511)
            nextHeight = renderData.waveformData[1][i+1];
        else
            nextHeight = height;

        glVertex2i(i, 0);
        glVertex2i(i, height);
        glVertex2i(i+1, nextHeight);
        glVertex2i(i+1, 0);
    }
    glEnd();

    SwapBuffers(windowDC);
}

// resize rendering viewport
void ResizeGL(Rect windowRect)
{
    windowWidth = windowRect.right - windowRect.left;
    windowHeight = windowRect.bottom - windowRect.top;

    if (windowHeight == 0) windowHeight = 1;

    glViewport(0, 0, windowWidth, windowHeight);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    glOrtho(0, windowWidth, 0, windowHeight, -1, 1);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

// cleanup OpenGL rendering context
void CleanupGL()
{
    wglMakeCurrent(NULL, NULL);

    if (windowRC != NULL)
    {
        wglDeleteContext(windowRC);
        windowRC = NULL;
    }

    if (windowDC)
    {
        ReleaseDC(windowHandle, windowDC);
        windowDC = NULL;
    }
}
*/

// handle messages sent by iTunes
//OSStatus pluginMessageHandler(OSType message, VisualPluginMessageInfo *messageInfo, void *refCon)
OSStatus VisualPluginHandler(OSType message, VisualPluginMessageInfo * messageInfo, void * refCon)
{
    OSStatus status = noErr;

    switch (message)
    {
        // sent when the plugin is loaded/unloaded
        case kVisualPluginInitMessage:
        case kVisualPluginCleanupMessage:
            break;

        // sent when plugin is enabled/disabled, plugin should handle these messages and do nothing
        case kVisualPluginEnableMessage:
        case kVisualPluginDisableMessage:
            break;

        // redraw the screne while idle
        case kVisualPluginIdleMessage:
            if (playing == false)
                //RenderGL();

            break;

        // sent when the visualizer is shown
        case kVisualPluginShowWindowMessage:
            //InitializeGL(messageInfo->u.showWindowMessage.window);
            //ResizeGL(messageInfo->u.setWindowMessage.drawRect);
            //RenderGL();
        
            break;

        // sent when the visualizer is hidden
        case kVisualPluginHideWindowMessage:
            //CleanupGL();

            break;

        // sent when visualizer viewport size is changed
        case kVisualPluginSetWindowMessage:
            //ResizeGL(messageInfo->u.setWindowMessage.drawRect);
            //RenderGL();

            break;

        // sent when visualizer should render a frame
        case kVisualPluginRenderMessage:
            //renderData = *messageInfo->u.renderMessage.renderData;
            //RenderGL();

            break;

        // sent when visualizer should update itself
        case kVisualPluginUpdateMessage:
            //RenderGL();

            break;

        // sent when player is stopped or paused
        case kVisualPluginStopMessage:
        case kVisualPluginPauseMessage:
            playing = false;

            break;

        // sent when player is started or unpaused
        case kVisualPluginPlayMessage:
        case kVisualPluginUnpauseMessage:
            playing = true;

            break;

        default:
            status = unimpErr;

            break;
    }

    return status;  
}

// register plugin with iTunes
//OSStatus registerPlugin(PluginMessageInfo *messageInfo)
OSStatus PlayerRegisterVisualPlugin (void *appCookie, ITAppProcPtr appProc, PlayerMessageInfo *messageInfo)
{
    // plugin constants
    const string pluginTitle = "Waveform";
    const UInt8 pluginMajorVersion = 1;
    const UInt8 pluginMinorVersion = 0;
    const UInt32 pluginCreator = '\?\?\?\?';

    PlayerMessageInfo playerMessageInfo;
    memset(&playerMessageInfo.u.registerVisualPluginMessage, 0, sizeof(playerMessageInfo.u.registerVisualPluginMessage));

    // copy in name length byte first
    playerMessageInfo.u.registerVisualPluginMessage.name[0] = (UInt8)pluginTitle.length();

    // now copy in actual name
    memcpy(&playerMessageInfo.u.registerVisualPluginMessage.name[1], pluginTitle.c_str(), pluginTitle.length());

    SetNumVersion(&playerMessageInfo.u.registerVisualPluginMessage.pluginVersion, pluginMajorVersion, pluginMinorVersion, 0x80, 0);

    playerMessageInfo.u.registerVisualPluginMessage.options = kVisualWantsIdleMessages;
    playerMessageInfo.u.registerVisualPluginMessage.handler = pluginMessageHandler;
    playerMessageInfo.u.registerVisualPluginMessage.registerRefCon = 0;
    playerMessageInfo.u.registerVisualPluginMessage.creator = pluginCreator;

    playerMessageInfo.u.registerVisualPluginMessage.timeBetweenDataInMS = 0xFFFFFFFF; // 16 milliseconds = 1 Tick, 0xFFFFFFFF = Often as possible.
    playerMessageInfo.u.registerVisualPluginMessage.numWaveformChannels = 2;
    playerMessageInfo.u.registerVisualPluginMessage.numSpectrumChannels = 2;

    playerMessageInfo.u.registerVisualPluginMessage.minWidth = 64;
    playerMessageInfo.u.registerVisualPluginMessage.minHeight = 64;
    playerMessageInfo.u.registerVisualPluginMessage.maxWidth = 32767;
    playerMessageInfo.u.registerVisualPluginMessage.maxHeight = 32767;
    playerMessageInfo.u.registerVisualPluginMessage.minFullScreenBitDepth = 0;
    playerMessageInfo.u.registerVisualPluginMessage.maxFullScreenBitDepth = 0;
    playerMessageInfo.u.registerVisualPluginMessage.windowAlignmentInBytes = 0;

    OSStatus status = PlayerRegisterVisualPlugin(messageInfo->u.initMessage.appCookie, messageInfo->u.initMessage.appProc, &playerMessageInfo);

    return status;
}

//extern "C" __declspec(dllexport) OSStatus iTunesPluginMain(OSType message, PluginMessageInfo *messageInfo, void *refCon)
//extern "C" OSStatus iTunesPluginMain(OSType message, PluginMessageInfo *messageInfo, void *refCon)
OSStatus main(OSType message, PluginMessageInfo * messageInfo, void * refCon)
{
    OSStatus status;

    switch (message)
    {
        case kPluginInitMessage:
            status = registerPlugin(messageInfo);
            break;

        case kPluginCleanupMessage:
            status = noErr;
            break;

        default:
            status = unimpErr;
            break;
    }

    return status;
}