#### {% title "RVM – zarządzanie wersjami Ruby+Rails" %}

W użyciu jest wiele implementacji i wersji języka Ruby. Dla przykładu:
Ruby MRI w wersjach 1.8.7, 1.9.3, 2.0.0, Ruby Enterprise Edition – 1.8.7,
jRuby – 1.5.0, Rubinius – 1.0.1, MagLev, IronRuby – 1.0.

Ruby Version Manager umożliwia zainstalowanie i przełączanie
się między różnymi implementacjami i wersjami języka Ruby.


# RVM – Ruby Version Manager

Dlaczego [RVM] [rvm]?
„RVM helps ensure that all aspects of ruby are completely contained
within user space, strongly encouraging **non-root usage**.”

Podstawowe polecenia RVM:

    :::bash
    rvm install 2.0.0-p0
    rvm --default use 2.0.0-p0 # ustawiamy domyślną wersję
    rvm remove --archive --gems 1.9.3-p327
    rvm use 1.9.3-p392

[Instalacja patchowanej wersji Ruby](http://astrails.com/blog/2012/11/13/rvm-install-patched-ruby-for-faster-rails-startup):

    :::bash
    rvm get head # uaktualnij RVM
    ls $rvm_path/patches/ruby/1.9.3/p392
      railsexpress
    rvm install 1.9.3-p392 --patch railsexpress -n railsexpress

Łata railsexpress przyśpiesza uruchamianie aplikacji Rails.
Zobacz też
[Making your ruby fly](http://alisnic.net/blog/making-your-ruby-fly/) na blogu Andrei Lisnica.
Na przykład:

    :::bash
    time rake routes # 3.6s dla 1.9.3
    time rake routes # 1.7s dla 1.9.3+ railsexpress
    time rake routes # 1.9s dla 2.0.0

Podstawowe informacje:

    :::bash
    rvm list
    rvm current

Więcej szczegółów:

    :::bash
    rvm env
    rvm disk-usage all # dla sześciu wersji języka ruby + gemy

        Downloaded Archives Usage: 39M
               Repositories Usage: 136M
      Extracted Source Code Usage: 1,1G
                  Log Files Usage: 1,5M
                   Packages Usage: 1,2M
                     Rubies Usage: 293M
                    Gemsets Usage: 1,7G
                   Wrappers Usage: 472K
            Temporary Files Usage: 4,0K
                Other Files Usage: 7,5M
                 Total Disk Usage: 3,2G

    rvm disk-usage total

      Total Disk Usage: 3,2G


## Zestawy gemów

W trakcie instalacji dla każdej wersji Rubiego
tworzone są dwa zestawy gemów (ang. *gemset*):

* **default** (domyślny, bez nazwy)
* **global**


## Rails & Bundler

Gemy możemy zainstalować lokalnie, na przykład w katalogu *.gems*:

    :::bash
    bundle install --path=$HOME/.gems

Od tej chwili, polecenie *bundle* będzie instalować gemy w podanej lokalizacji.


# Roadmap for Learning Rails

Roadmap specially designed for a beginner to navigate their way to Rails mastery.

{%= image_tag "/images/Learning-Rails-Roadmap.png", :alt => "[Learning Rails Roadmap]" %}

[Źródło](http://techiferous.com/2010/07/roadmap-for-learning-rails/)


[rvm]: http://rvm.beginrescueend.com/ "Ruby Version Manager"
