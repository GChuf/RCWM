#include <windows.h>

int main() {
    // Your command (e.g., write to file)
    const char* cmd = "cmd.exe /c powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File C:\\git\\rcwm\\RCWM\\files\\ExecutionFiles\\rcp.ps1\"";

    // Start hidden process
    STARTUPINFOA si = { sizeof(si) };
    PROCESS_INFORMATION pi;
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = SW_HIDE;

    CreateProcessA(
        NULL,
        (LPSTR)cmd,
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