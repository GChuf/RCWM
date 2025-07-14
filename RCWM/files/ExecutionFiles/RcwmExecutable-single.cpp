#include <windows.h>
#include <string>

#pragma comment(lib, "Advapi32.lib")

//open x86 Native Tools Command Prompt for VS 2022
//C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2022\Visual Studio Tools\VC
// 
//cl /O2 /Os /nologo /Fe:rcwm-single.exe RcwmExecutable-single.cpp /link /OPT:REF /OPT:ICF Advapi32.lib /SUBSYSTEM:WINDOWS /ENTRY:wWinMainCRTStartup

int WINAPI wWinMain(HINSTANCE, HINSTANCE, LPWSTR arg, int) {
    HKEY hSubKey;

    std::wstring fullArg(arg);

    if (fullArg.length() < 7 || fullArg[5] != L' ') {
        return 1; // invalid format
    }

    std::wstring regKey = fullArg.substr(0, 5);
    std::wstring directoryPath = fullArg.substr(6);
    std::wstring regKeyPath = L"Software\\RCWM\\" + regKey;

    if (RegOpenKeyExW(HKEY_CURRENT_USER, regKeyPath.c_str(), 0, KEY_READ | KEY_WRITE, &hSubKey) == ERROR_SUCCESS) {
        // Delete all existing values
        wchar_t nameBuf[256];
        DWORD nameLen;
        while (true) {
            nameLen = sizeof(nameBuf) / sizeof(wchar_t);
            if (RegEnumValueW(hSubKey, 0, nameBuf, &nameLen, NULL, NULL, NULL, NULL) != ERROR_SUCCESS)
                break;
            RegDeleteValueW(hSubKey, nameBuf);
        }
        // Store registry value with REG_NONE and empty data
        RegSetValueExW(hSubKey, directoryPath.c_str(), 0, REG_NONE, NULL, 0);
        RegCloseKey(hSubKey);
    }

    return 0;
}
