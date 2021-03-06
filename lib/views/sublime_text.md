#### {% title "Sublime Text 2" %}

* [Sublime Text](http://www.sublimetext.com/)
* [Perfect Workflow in Sublime Text 2](https://tutsplus.com/course/improve-workflow-in-sublime-text-2/) – screencasts
* [Sublime Text 2 Documentation](http://www.sublimetext.com/docs/2/)


## Rzeczy podstawowe

Ukrywamy zbędne rzeczy:

* View > Hide Minimap
* View > Side Bar > Hide Side Bar

Instalujemy [Package Control](http://wbond.net/sublime\_packages/package\_control).

Instalujemy pakiety: z menu **Preferences » Package Control**
wbieramy **Install**, gdzie wpisujemy nazwę pakietu:

* [Git](https://github.com/kemayo/sublime-text-2-git/wiki)
* *LESS syntax highlighting*
* *TrailingSpaces*
* *ERB insert and toggle commands*


## Preferences

**» Settings – User**:

    :::json Preferences.sublime-settings
    {
      "color_scheme": "Packages/Color Scheme - Default/Sunburst.tmTheme",
      "font_face": "Terminus",
      "font_size": 14,
      "tab_size": 2,
      "translate_tabs_to_spaces": true,
      "rulers": [78],
      "caret_style": "wide",
      "highlight_line": true,
      "line_padding_bottom": 2,
      "line_padding_top": 2,
      "fade_fold_buttons": false,
      "bold_folder_labels": true
    }

**» Settings – More » Syntax Specific**:

    :::json Markdown.sublime-settings
    {
      "tab_size": 2,
      "translate_tabs_to_spaces": true
    }

Zbędne. Ale dla plików *Makefile* należy ustawić *translate_tabs_to_spaces*
na *false*.

**» Key Bindings – User**:

    :::json User/Default.sublime-keymap
    [
      { "keys": ["ctrl+\\"], "command": "reindent" },
      { "keys": ["ctrl+k", "ctrl+t"], "command": "title_case" },
      { "keys": ["ctrl+u"], "command": "expand_tabs" },
      // non-break space
      { "keys": ["super+`"], "command": "insert", "args": {"characters": " "} },
      // wtyczki
      { "keys": ["ctrl+shift+."], "command": "erb" },
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
* lower case: `ctrl+k ctrl+l`
* title case: `ctrl+k ctrl+t`
* usuń do końca wiersza: `ctrl+k ctrl+k`
* usuń do początku wiersza: `ctrl+k ctrl+backspace`

## Ruby

Pakiety:

* Auto Encoding for Ruby
* RubyEval

Skróty klawiszowe:

* super+k, super+e


## Rails…

Otwieramy katalog z aplikacją Rails. Pliki wyszukujemy
za pomocą *Goto Anything* (`ctrl+p`).

Nowe snippets dla Rails:

* [instalacja Sublime Text 2 Rails snippets](https://github.com/tadast/sublime-rails-snippets)
* [skróty](http://tadast.github.com/sublime-rails-snippets/)

Szablon projektu dla aplikacji Rails:

    :::json rails.sublime-project
    {
      "folders": [
        {
          "path": ".",
          "folder_exclude_patterns": ["tmp", "log", "vendor", "script", "public"],
          "file_exclude_patterns": ["config.ru", "Gemfile.lock", "Rakefile", ".gitignore"]
        }
      ],
      "settings": {
        "tab_size": 2
      }
    }