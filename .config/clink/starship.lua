load(io.popen('starship init cmd'):read('*a'))()

clink.oninject(function()
    os.execute('sh "%USERPROFILE%/.config/shell/scripts/startup.sh" cmd')
    os.setenv('HEADER_PARENT_SHELL', 'cmd')
end)
