if (window.get_active_class() == 'google-chrome.Google-chrome' or \
    window.get_active_class() == 'chromium-browser.Chromium-browser'):
    store.set_global_value('hotkey', '<alt>+q')
    store.set_global_value('keycmd', '<alt>+f')
    engine.run_script('combo')
    store.set_global_value('hotkey', '<alt>+q')
    store.set_global_value('keycmd', 'x')
    engine.run_script('combo')
else:
    store.set_global_value('hotkey', '<alt>+q')
    store.set_global_value('keycmd', '<ctrl>+q')
    engine.run_script('combo')
