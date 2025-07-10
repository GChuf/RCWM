#include <windows.h>
#pragma comment(lib, "Advapi32.lib")
#include <string>

// cl /O2 /Os /nologo /Fe:rcwm-reg.exe RcwmExecutable.cpp /link  /OPT:REF /OPT:ICF Advapi32.lib  /SUBSYSTEM:WINDOWS
// rcwm-reg.exe rgkey test
// -> HKEY_CURRENT_USER\SOFTWARE\RCWM\rgkey

//dlink
//flink
//miror
//rmove
//rcopy
//rstrc


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

    std::string regKey = fullArg.substr(0, 5);
    std::string directoryPath = fullArg.substr(6); // everything after first 5 chars and the whitespace, no need to put into double quotes

    std::string regKeyPath = "Software\\RCWM\\" + regKey;
    //const char* regKeyPath = "Software\\RCWM\\dl";

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

    if (RegOpenKeyExA(HKEY_CURRENT_USER, regKeyPath.c_str(), 0, KEY_READ | KEY_WRITE, &hSubKey) == ERROR_SUCCESS) {
        RegSetValueExA(hSubKey, directoryPath.c_str(), 0, REG_NONE, NULL, 0);
        RegCloseKey(hSubKey);
    }

    //RegOpenKeyA(HKEY_CURRENT_USER, regKeyPath.c_str(), &hSubKey);
    //RegOpenKeyExA(HKEY_CURRENT_USER, regKeyPath.c_str(), 0, KEY_READ | KEY_WRITE, &hSubKey);
    //RegSetValueExA(hSubKey, directoryPath.c_str(), 0, REG_NONE, NULL, 0);
    //LogToFile(result == ERROR_SUCCESS ? "Registry write successful" : "Registry write failed");
    //RegCloseKey(hSubKey);


    return 0;
}