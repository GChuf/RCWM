#include <windows.h>
#include <string>

// cl /O2 /Os /nologo /Fe:rcwm-ps1.1.exe RcwmExecPowershell.cpp /link  /OPT:REF /OPT:ICF Advapi32.lib  /SUBSYSTEM:CONSOLE

int main(int argc, char* argv[]) {

    //argc always 3
    //third argument (path) needs to be inside double quotes, because arguments are delimited by spaces
    // 
    // 
    // 
    std::string method = argv[1];
    std::string mode = argv[2];
    std::string path = argv[3];


    // Your command (e.g., write to file)
    //const char* cmd = "cmd.exe /c powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File C:\\git\\rcwm\\RCWM\\files\\ExecutionFiles\\rcp.ps1" + method + " " + mode + " " + path;
    std::string cmd = "cmd.exe /c powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File C:\\git\\rcwm\\RCWM\\files\\ExecutionFiles\\rcp.ps1 " + method + " " + mode + " " + path;
    const char* command = cmd.c_str();

    // Start process
    STARTUPINFOA si = { sizeof(si) };
    PROCESS_INFORMATION pi;
    si.dwFlags = STARTF_USESHOWWINDOW;


    CreateProcessA(
        NULL,
        (LPSTR)command,
        NULL,
        NULL,
        FALSE,
        0,
        NULL,
        NULL,
        &si,
        &pi
    );

    // Close handles
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    return 0;
}