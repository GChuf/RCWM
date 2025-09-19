#include <windows.h>
#include <string>

#pragma comment(lib, "Advapi32.lib")

//cl /O2 /Os /nologo /Fe:InitRegKeys.exe initregkeys.cpp /link /OPT:REF /OPT:ICF Advapi32.lib /SUBSYSTEM:WINDOWS /ENTRY:wWinMainCRTStartup

int WINAPI wWinMain(HINSTANCE, HINSTANCE, LPWSTR, int) {
    HKEY hBaseKey = nullptr;
    HKEY hSubKey = nullptr;

    const std::wstring basePath = L"Software\\RCWM";

    // Check if base RCWM key exists, create if missing
    LONG baseResult = RegOpenKeyExW(HKEY_CURRENT_USER, basePath.c_str(), 0, KEY_READ | KEY_WRITE, &hBaseKey);
    if (baseResult != ERROR_SUCCESS) {
        if (RegCreateKeyExW(
                HKEY_CURRENT_USER,
                basePath.c_str(),
                0,
                NULL,
                REG_OPTION_NON_VOLATILE,
                KEY_WRITE,
                NULL,
                &hBaseKey,
                NULL) != ERROR_SUCCESS) {

            return 1;
        }
    }
    RegCloseKey(hBaseKey);

    // Subkeys to check/create
    std::wstring regKeys[] = { L"dlink", L"flink", L"miror", L"rcmov", L"rcopy", L"rstrc" };

    for (const auto& key : regKeys) {
        std::wstring fullPath = basePath + L"\\" + key;

        LONG result = RegOpenKeyExW(HKEY_CURRENT_USER, fullPath.c_str(), 0, KEY_READ | KEY_WRITE, &hSubKey);
        if (result != ERROR_SUCCESS) {
            if (RegCreateKeyExW(
                    HKEY_CURRENT_USER,
                    fullPath.c_str(),
                    0,
                    NULL,
                    REG_OPTION_NON_VOLATILE,
                    KEY_WRITE,
                    NULL,
                    &hSubKey,
                    NULL) == ERROR_SUCCESS) {
                RegCloseKey(hSubKey);
            }
        } else {
            RegCloseKey(hSubKey);
        }
    }

    return 0;
}
