#### {% title "Sublime Text 2" %}

* [Sublime Text](http://www.sublimetext.com/)
* [Perfect Workflow in Sublime Text 2](https://tutsplus.com/course/improve-workflow-in-sublime-text-2/) – screencasts
* [Sublime Text 2 Documentation](http://www.sublimetext.com/docs/2/)


## Rzeczy podstawowe

* View > Hide Minimap
* View > Side Bar > Hide Side Bar


## Preferences

**» Settings – User**:

    :::json Preferences.sublime-settings
    {
      "color_scheme": "Packages/Color Scheme - Default/Sunburst.tmTheme",
      "font_face": "Terminus",
      "font_size": 14,
      "tab_size": 2,
      "translate_tabs_to_spaces": false
    }

**» Settings – More » Syntax Specific**:

    :::json Markdown.sublime-settings
    {
      "tab_size": 4,
      "translate_tabs_to_spaces": false
    }

**» Key Bindings – User**:

    :::json Default.sublime-keymap
    [
      { "keys": ["ctrl+\\"], "command": "reindent" },
      { "keys": ["ctrl+shift+."], "command": "erb" },
      { "keys": ["super+`"], "command": "insert", "args": {"characters": " "} },
      { "keys": ["ctrl+shift+t"], "command": "delete_trailing_spaces" }
    ]


### Większy font w *status bar*

W pliku *~/.config/sublime-text-2/Packages/Theme - Default/Default.sublime-theme*
dopisać *font.size* w tym elemencie:

    :::json Default.sublime-theme
    {
        "class": "label_control",
        "color": [255, 255, 255],
        "shadow_color": [24, 24, 24],
        "shadow_offset": [0, -1],
        "font.size": 18.0
    }


## Podstawowe skróty klawiszowe

Najważniejsze skróty:

* command palette (menu z wyszukiwaniem przyrostowym): `shift+ctrl+p`

Często używane skróty:

* goto anything:  `ctrl+p`
* autouzupełnianie: `alt+/`
* komentowanie bloku kodu: `ctrl+/`
* wielokrotne kursory: `ctrl+d`
* zaznaczanie prostokątne: `shift+right mouse button`

Pakiety:

* remove trailing spaces (package):  `ctrl+shift+t`


## Tools, Rails…

Brak snippetów dla Markdown. Przykładowy snippet:

* `link` – `[]()`

[Emmet](http://docs.emmet.io/) – the essential toolkit for web-developers:

* [emmet-sublime](https://github.com/sergeche/emmet-sublime)

Rails:

* otwieramy katalog z aplikacją Rails – teraz wyszukujemy
  plik z *Goto Anything* (`ctrl+p`)


## Package Control

Instalujemy [Package Control](http://wbond.net/sublime\_packages/package\_control).

Z menu **Preferences » Package Control**, **Install** wpisujemy nazwę pakietu:

* pakiet [Git](https://github.com/kemayo/sublime-text-2-git/wiki)
* pakiety: *LESS syntax highlighting*, *ERB insert and toggle commands*