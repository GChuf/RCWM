#include <windows.h>
#include <string>

#pragma comment(lib, "Advapi32.lib")

//open x86 Native Tools Command Prompt for VS 2022
//C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2022\Visual Studio Tools\VC
// 
//cl /GL /O2 /Os /nologo /Fe:rcwm-multiple.exe RcwmExecutable-multiple.cpp /link /OPT:REF /OPT:ICF Advapi32.lib /SUBSYSTEM:WINDOWS /ENTRY:wWinMainCRTStartup

int WINAPI wWinMain(HINSTANCE, HINSTANCE, LPWSTR arg, int) {
    HKEY hSubKey;

    std::wstring fullArg(arg);

    if (fullArg.length() < 7 || fullArg[5] != L' ') {
        return 1; // invalid format
    }

    std::wstring regKey = fullArg.substr(0, 5);
    std::wstring directoryPath = fullArg.substr(6); // after space
    std::wstring regKeyPath = L"Software\\RCWM\\" + regKey;

    if (RegOpenKeyExW(HKEY_CURRENT_USER, regKeyPath.c_str(), 0, KEY_READ | KEY_WRITE, &hSubKey) == ERROR_SUCCESS) {
        // Store registry value with REG_NONE and empty data
        RegSetValueExW(hSubKey, directoryPath.c_str(), 0, REG_NONE, NULL, 0);
        RegCloseKey(hSubKey);
    }

    return 0;
}
