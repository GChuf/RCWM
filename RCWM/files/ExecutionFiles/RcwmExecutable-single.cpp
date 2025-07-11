#include <windows.h>
#include <string>

#pragma comment(lib, "Advapi32.lib")

int WINAPI wWinMain(HINSTANCE, HINSTANCE, LPWSTR arg, int) {
    HKEY hSubKey;

    std::wstring fullArg(arg);  // Already Unicode (UTF-16)

    if (fullArg.length() < 7 || fullArg[5] != L' ') {
        return 1; // invalid format
    }

    std::wstring regKey = fullArg.substr(0, 5);
    std::wstring directoryPath = fullArg.substr(6);

    std::wstring regKeyPath = L"Software\\RCWM\\" + regKey;
    std::wstring valueName = directoryPath;

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

        const wchar_t* dummyValue = L"Test čžš";
        RegSetValueExW(hSubKey, valueName.c_str(), 0, REG_SZ,
            reinterpret_cast<const BYTE*>(dummyValue),
            (DWORD)((wcslen(dummyValue) + 1) * sizeof(wchar_t)));

        RegCloseKey(hSubKey);
    }

    return 0;
}
