#define UNICODE
#define _UNICODE
#include <windows.h>
#include <shellapi.h>
#include <string>
#include <vector>
#include <fstream>
#include <iostream>

static bool writeResourceToFile(const wchar_t* name, const std::wstring& path) {
    HRSRC hrsrc = FindResourceW(NULL, name, RT_RCDATA);
    if (!hrsrc) return false;
    HGLOBAL hglob = LoadResource(NULL, hrsrc);
    if (!hglob) return false;
    DWORD size = SizeofResource(NULL, hrsrc);
    void* data = LockResource(hglob);
    if (!data || size == 0) return false;

    std::ofstream out(path.c_str(), std::ios::binary);
    if (!out) return false;
    out.write(reinterpret_cast<const char*>(data), size);
    return out.good();
}

static bool ensureDir(const std::wstring& path) {
    if (CreateDirectoryW(path.c_str(), NULL)) return true;
    return GetLastError() == ERROR_ALREADY_EXISTS;
}

int wmain(int argc, wchar_t** argv) {
    std::wcout << L"#################### НАЧАЛО ВЫВОДА: V2RAYN WIN7 REMNAWAVE SETUP ####################\n";

    wchar_t temp[MAX_PATH] = {0};
    if (!GetTempPathW(MAX_PATH, temp)) {
        std::wcerr << L"[ОШИБКА] Не удалось получить TEMP.\n";
        return 10;
    }

    std::wstring root = std::wstring(temp) + L"v2rayn-win7-remnawave-setup";
    std::wstring scripts = root + L"\\scripts";
    ensureDir(root);
    ensureDir(scripts);

    struct Item { const wchar_t* res; const wchar_t* rel; };
    const Item items[] = {
        {L"PAYLOAD_INSTALL_CMD", L"INSTALL.cmd"},
        {L"PAYLOAD_COMMON_PS1", L"scripts\\common.ps1"},
        {L"PAYLOAD_INSTALL_PS1", L"scripts\\install.ps1"},
        {L"PAYLOAD_UPDATE_PS1", L"scripts\\update-xray.ps1"},
        {L"PAYLOAD_REPAIR_PS1", L"scripts\\repair.ps1"},
        {L"PAYLOAD_DIAG_PS1", L"scripts\\diag.ps1"}
    };

    for (size_t i = 0; i < sizeof(items)/sizeof(items[0]); ++i) {
        std::wstring target = root + L"\\" + items[i].rel;
        if (!writeResourceToFile(items[i].res, target)) {
            std::wcerr << L"[ОШИБКА] Не удалось извлечь " << items[i].rel << L"\n";
            return 20;
        }
    }

    std::wstring cmd = L"\"" + root + L"\\INSTALL.cmd\"";
    if (argc > 1 && argv[1] && wcslen(argv[1]) > 0) {
        cmd += L" \"";
        cmd += argv[1];
        cmd += L"\"";
    }

    SHELLEXECUTEINFOW sei = { sizeof(sei) };
    sei.fMask = SEE_MASK_NOCLOSEPROCESS;
    sei.lpVerb = L"open";
    sei.lpFile = L"cmd.exe";
    std::wstring params = L"/d /s /c " + cmd;
    sei.lpParameters = params.c_str();
    sei.lpDirectory = root.c_str();
    sei.nShow = SW_SHOWNORMAL;

    if (!ShellExecuteExW(&sei) || !sei.hProcess) {
        std::wcerr << L"[ОШИБКА] Не удалось запустить установщик.\n";
        return 30;
    }

    WaitForSingleObject(sei.hProcess, INFINITE);
    DWORD code = 1;
    GetExitCodeProcess(sei.hProcess, &code);
    CloseHandle(sei.hProcess);

    std::wcout << L"[INFO] Код завершения установки: " << code << L"\n";
    std::wcout << L"#################### КОНЕЦ ВЫВОДА: V2RAYN WIN7 REMNAWAVE SETUP ####################\n";
    return static_cast<int>(code);
}
