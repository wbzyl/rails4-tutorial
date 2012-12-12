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
      { "keys": ["ctrl+shift+."], "command": "erb" }
    ]


## Podstawowe skróty klawiszowe

* uzupełnianie: `alt+/`
* wyszukiwanie plików:  `ctrl+p`
* command palette: `shift+ctrl+p`
* remove trailing spaces (package):  `ctrl+shift+t`


## Tools » New Snippet…

Brak snippetów dla Markdown. Przykładowy snippet:

* `link` – `[]()`


## Package Control & Rails


Instalujemy [Package Control](http://wbond.net/sublime\_packages/package\_control).
Następnie z menu wybieramy **Preferences » Package Control**

* i instalujemy pakiety: *LESS syntax highlighting*, *ERB insert and toggle commands*
* a pliki wyszukujemy korzystając z *Goto Anything* (`ctrl+p`)