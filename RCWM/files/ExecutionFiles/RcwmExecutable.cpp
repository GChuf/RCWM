#include <windows.h>
#pragma comment(lib, "Advapi32.lib")
#include <string>
/*
void LogToFile(const char* message) {
    const char* logPath = "C:\\Users\\root\\Desktop\\reg_log.txt";
    HANDLE hFile = CreateFileA(logPath, FILE_APPEND_DATA, FILE_SHARE_READ,
        NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile != INVALID_HANDLE_VALUE) {
        DWORD bytesWritten;
        WriteFile(hFile, message, (DWORD)strlen(message), &bytesWritten, NULL);
        WriteFile(hFile, "\r\n", 2, &bytesWritten, NULL);
        CloseHandle(hFile);
    }
}
*/
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR arg, int) {
    // Registry operations
    //HKEY hKey;
    HKEY hSubKey;


    std::string fullArg(arg);

    std::string regKey = fullArg.substr(0, 2);
    std::string directoryPath = fullArg.substr(3); // everything after first 2 chars

    std::string regKeyFullPath = "Software\\RCWM\\" + regKey;
    //const char* regKeyFullPath = "Software\\RCWM\\dl";

    /*
    LONG result = RegCreateKeyExA(HKEY_CURRENT_USER, keyPath, 0, NULL, 0, KEY_WRITE, NULL, &hKey, NULL);
    //LogToFile("arg:");
    //LogToFile(path);
    if (result == ERROR_SUCCESS) {
        //const char* valueData = "MyValueData";
        result = RegSetValueExA(hKey, path, 0, REG_SZ, NULL, 0);
        //LogToFile(result == ERROR_SUCCESS ? "Registry write successful" : "Registry write failed");
        RegCloseKey(hKey);
    }
    else {
        //LogToFile("Failed to open/create registry key");
    }
    */

    RegOpenKeyA(HKEY_CURRENT_USER, regKeyFullPath.c_str(), &hSubKey);
    RegSetValueExA(hSubKey, directoryPath.c_str(), 0, REG_NONE, NULL, 0);
    //LogToFile(result == ERROR_SUCCESS ? "Registry write successful" : "Registry write failed");
    RegCloseKey(hSubKey);


    return 0;
}