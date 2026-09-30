# start menu launches open in system32
if ($IsWindows -and $PWD.Path -eq [Environment]::SystemDirectory) {
    Set-Location $HOME
}

# uptime header
if (Get-Command sh -ErrorAction Ignore) {
    sh "$HOME/.config/shell/scripts/startup.sh" pwsh
    $env:HEADER_PARENT_SHELL = 'pwsh'
}

# starship (prompt)
Invoke-Expression (&starship init powershell)

# zoxide
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })

# mise
mise activate pwsh | Out-String | Invoke-Expression

# vcpkg
if ($IsWindows) {
    $env:VCPKG_ROOT = "$HOME\vcpkg"
    $env:PATH = "$env:VCPKG_ROOT;$env:PATH"
}

# eza
Remove-Item alias:ls -ErrorAction SilentlyContinue
function ls {
    eza @args
}
if (Get-Command vivid -ErrorAction Ignore) {
    $env:LS_COLORS = vivid generate gruvbox-dark
}

# atuin
atuin init powershell --disable-up-arrow | Out-String | Invoke-Expression

# second claude account
function claude2 {
    $prev = $env:CLAUDE_CONFIG_DIR
    $env:CLAUDE_CONFIG_DIR = "$HOME/.claude2"
    try { claude @args } finally { $env:CLAUDE_CONFIG_DIR = $prev }
}
