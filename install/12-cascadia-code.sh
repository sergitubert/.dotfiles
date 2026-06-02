CASCADIA_VERSION=$(curl -s "https://api.github.com/repos/microsoft/cascadia-code/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -sLo /tmp/cascadia-code.zip "https://github.com/microsoft/cascadia-code/releases/latest/download/CascadiaCode-${CASCADIA_VERSION}.zip"
sudo apt install -y unzip
unzip -o /tmp/cascadia-code.zip 'ttf/*' -d /tmp/cascadia-code

# Linux-side fonts (for native Linux terminal emulators)
mkdir -p "$HOME/.local/share/fonts/CascadiaCode"
cp /tmp/cascadia-code/ttf/*.ttf "$HOME/.local/share/fonts/CascadiaCode/"
fc-cache -fv

# WSL2: also install NF variants into the Windows user fonts directory so
# Windows Terminal can use them without requiring admin rights.
if grep -qi "microsoft" /proc/version 2>/dev/null; then
  WINDOWS_USER=$(wslvar USERNAME 2>/dev/null || ls /mnt/c/Users/ | grep -vE '^(Default|Public|All Users|Default User)$' | grep -v desktop.ini | head -1)
  WINDOWS_FONTS="/mnt/c/Users/${WINDOWS_USER}/AppData/Local/Microsoft/Windows/Fonts"
  if [ -d "$WINDOWS_FONTS" ]; then
    cp /tmp/cascadia-code/ttf/CascadiaCodeNF*.ttf "$WINDOWS_FONTS/"
    POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
    if [ -x "$POWERSHELL" ]; then
      "$POWERSHELL" -Command "
        \$regPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        Get-ChildItem '${WINDOWS_FONTS//\//\\}\CascadiaCodeNF*.ttf' | ForEach-Object {
          \$fc = New-Object System.Drawing.Text.PrivateFontCollection
          \$fc.AddFontFile(\$_.FullName)
          \$name = \$fc.Families[0].Name + ' (TrueType)'
          New-ItemProperty -Path \$regPath -Name \$name -Value \$_.FullName -PropertyType String -Force | Out-Null
        }
      "
    fi
  fi
fi

rm -rf /tmp/cascadia-code.zip /tmp/cascadia-code
