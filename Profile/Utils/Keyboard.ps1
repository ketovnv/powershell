Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

Function Switch-KeyboardLayout
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("en-US", "ru-RU", "uk-UA")]
        [string]$Culture
    )

    # Сопоставление культур с соответствующими HEX-кодами раскладок Windows
    $layoutMap = @{
        "en-US" = "00000409"
        "ru-RU" = "00000419"
        "uk-UA" = "00000422"
    }

    if (-not $layoutMap.ContainsKey($Culture))
    {
        Write-Warning "Неизвестная раскладка: $Culture"
        return
    }

    $klid = $layoutMap[$Culture]

    # Проверяем, не был ли тип уже добавлен
    if (-not ([System.Management.Automation.PSTypeName]'KeyboardLayoutSwitcher').Type)
    {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        using System.Globalization;

        public class KeyboardLayoutSwitcher {
            [DllImport("user32.dll")]
            public static extern IntPtr LoadKeyboardLayout(string pwszKLID, uint Flags);

            [DllImport("user32.dll")]
            public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

            [DllImport("user32.dll")]
            public static extern IntPtr GetForegroundWindow();

            [DllImport("user32.dll")]
            public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

            [DllImport("user32.dll")]
            public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

            [DllImport("user32.dll")]
            public static extern bool IsWindowVisible(IntPtr hWnd);

            public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

            private const uint WM_INPUTLANGCHANGEREQUEST = 0x0050;
            private const IntPtr INPUTLANGCHANGE_SYSCHARSET = (IntPtr)0x0001;
            private const int KLF_ACTIVATE = 0x00000001;

            public static bool SwitchKeyboardLayout(string layoutId) {
                try {
                    // Загружаем раскладку
                    IntPtr hkl = LoadKeyboardLayout(layoutId, KLF_ACTIVATE);
                    if (hkl == IntPtr.Zero) {
                        return false;
                    }

                    // Отправляем сообщение всем окнам
                    EnumWindows((hWnd, lParam) => {
                        if (IsWindowVisible(hWnd)) {
                            PostMessage(hWnd, WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_SYSCHARSET, hkl);
                        }
                        return true;
                    }, IntPtr.Zero);

                    // Также отправляем сообщение активному окну
                    IntPtr foregroundWindow = GetForegroundWindow();
                    if (foregroundWindow != IntPtr.Zero) {
                        PostMessage(foregroundWindow, WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_SYSCHARSET, hkl);
                    }

                    return true;
                } catch {
                    return false;
                }
            }
        }
"@
    }

    try
    {
        $success = [KeyboardLayoutSwitcher]::SwitchKeyboardLayout($klid)

        if ($success)
        {
            Write-Verbose "✅ $Culture"
            Start-Sleep -Milliseconds 50
        }
        else
        {
            Write-Error "Не удалось переключить раскладку на $Culture. Убедитесь, что раскладка установлена в системе."
        }

    }
    catch
    {
        Write-Error "Ошибка при переключении раскладки: $( $_.Exception.Message )"
    }
}

#function ru {
#    Switch-KeyboardLayoutпппппппппп
#}

function en
{
    Switch-KeyboardLayout en-Us
    wrgb "⌨️ En" -FC "#1177BB"
}

Set-Alias -Name "йй" -Value en

function ru
{
    Switch-KeyboardLayout ru-Ru
    wrgb "⌨️ Рус"  -FC "#118855"
}

Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
