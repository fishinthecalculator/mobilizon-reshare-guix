(define-module (mobilizon-reshare package)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix build-system python)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages check)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages markup)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages time)
  #:use-module (mobilizon-reshare dependencies))

(define coopyleft
  (let ((license (@@ (guix licenses) license)))
    (license "Coopyleft"
             "https://wiki.coopcycle.org/en:license"
             "Coopyleft License")))

(define (mobilizon-reshare-origin version hash)
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/Tech-Workers-Coalition-Italia/mobilizon-reshare")
          (commit (string-append "v" version))))
    (sha256 (base32 hash))
    (file-name (git-file-name "mobilizon-reshare" version))
    (modules '((guix build utils)))
    (snippet
     #~(begin
         (let ((bash (string-append #$bash "/bin/bash"))
               (gzip (string-append #$gzip "/bin/gzip"))
               (poetry (string-append #$poetry "/bin/poetry"))
               (tar (string-append #$tar "/bin/tar"))
               (tests-script "./scripts/run_pipeline_tests.sh"))
           ;; This is an hack to obtain poetry's setup.py.
           (setenv "POETRY_VIRTUALENVS_CREATE" "false")
           (invoke poetry "build" "-f" "sdist")
           (invoke bash "-c" (string-append "cd dist && " gzip " -cd ./*-`" poetry " version -s`.tar.gz > out.tar"))
           (invoke bash "-c"
                   (string-append
                    tar " --wildcards -xvf dist/out.tar -O '*/setup.py' > setup.py"))
           ;; Reduce source size.
           (delete-file-recursively "dist")
           ;; In 0.1.0 we had no script.
           (when (file-exists? tests-script)
             (substitute* tests-script
               (("poetry") poetry))))))))

(define-public mobilizon-reshare-0.1.0
  (package
    (name "mobilizon-reshare")
    (version "0.1.0")
    (source
     (mobilizon-reshare-origin
      version
      "0vg6r28zq65vfsrcskypgq132psbvyw8pb88q1qyaq6f7k0yy1c0"))
    (build-system python-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'prevent-versions-enforcing
                 (lambda _
                   (substitute* "setup.py"
                     (("'install_requires': install_requires,") ""))))
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
                     (invoke "python" "-m" "pytest"
                             ;; This test fails because of the unvendoring
                             ;; of toml from dynaconf.
                             "-k" "not test_get_settings_failure_invalid_toml")))))))
    (native-inputs
     (list python-asynctest-from-the-past
           python-iniconfig
           python-pypika-tortoise
           python-pytest
           python-pytest-asyncio-0.15
           python-pytz
           python-responses))
    (propagated-inputs
     (list python-aiosqlite
           python-appdirs
           python-arrow
           python-beautifulsoup4
           python-click
           dynaconf
           python-jinja2
           python-markdownify
           python-requests-2.25
           python-tortoise-orm-0.17))
    (home-page
     "https://github.com/Tech-Workers-Coalition-Italia/mobilizon-reshare")
    (synopsis
     "Enables an organization to automate their social media strategy")
    (description
     "The goal of @code{mobilizon_reshare} is to provide a suite to reshare
Mobilizon events on a broad selection of platforms.  This tool enables an
organization to automate their social media strategy in regards to events and
their promotion.")
    (license coopyleft)))

(define-public mobilizon-reshare-0.2.0
  (package (inherit mobilizon-reshare-0.1.0)
    (name "mobilizon-reshare")
    (version "0.2.0")
    (source
     (mobilizon-reshare-origin
      version
      "0mssh89ag07sjbshqd8gzdadxakm1xs8iwdsnxfvvlb1f5lv3w6f"))
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'prevent-versions-enforcing
                 (lambda _
                   (substitute* "setup.py"
                     (("'install_requires': install_requires,") ""))))
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
                     (setenv "POETRY_VIRTUALENVS_CREATE" "false")
                     (invoke "./scripts/run_pipeline_tests.sh"))))
               (add-before 'sanity-check 'set-dummy-config
                 (lambda _
                   ;; This is needed to prevent the tool from
                   ;; crashing at startup during the sanity check.
                   (setenv "SECRETS_FOR_DYNACONF"
                           (string-append (getcwd)
                                          "/mobilizon_reshare/.secrets.toml")))))))
    (native-inputs
       (list python-iniconfig
             python-pytest
             python-pytest-cov
             python-pytest-asyncio
             python-pytest-lazy-fixture
             python-responses))
    (propagated-inputs
     (list (patch-for-mobilizon-reshare-0.2.0 python-aerich)
           python-aiosqlite
           python-appdirs
           python-arrow
           python-beautifulsoup4
           python-click
           dynaconf
           (patch-for-mobilizon-reshare-0.2.0 python-facebook-sdk.git)
           python-jinja2
           python-markdownify
           python-requests-2.25
           python-telegram-bot
           (patch-for-mobilizon-reshare-0.2.0 python-tweepy)
           (patch-for-mobilizon-reshare-0.2.0
            python-tortoise-orm-0.18.1)))))

(define-public mobilizon-reshare-0.2.2
  (package (inherit mobilizon-reshare-0.2.0)
    (name "mobilizon-reshare")
    (version "0.2.2")
    (source
     (mobilizon-reshare-origin
      version
      "0cgl0zkqq3z872qjzix0lqqmisgaavpj2rs0lxc5p0bfn698rmjl"))
    (arguments
     (substitute-keyword-arguments (package-arguments mobilizon-reshare-0.2.0)
       ((#:phases phases)
        #~(modify-phases #$phases
            (delete 'prevent-versions-enforcing)))))
    (propagated-inputs
         (list (patch-for-mobilizon-reshare-0.2.2 python-aerich)
               python-aiosqlite
               python-appdirs
               python-arrow
               python-beautifulsoup4
               python-click-8.0
               (patch-for-mobilizon-reshare-0.2.2 dynaconf)
               (patch-for-mobilizon-reshare-0.2.2 python-facebook-sdk)
               python-jinja2-3.0
               python-markdownify
               python-requests-2.25
               python-telegram-bot
               (patch-for-mobilizon-reshare-0.2.2 python-tweepy-4.1)
               (patch-for-mobilizon-reshare-0.2.2 python-tortoise-orm-0.18.1)))))

(define-public mobilizon-reshare-0.2.3
  (package (inherit mobilizon-reshare-0.2.2)
    (name "mobilizon-reshare")
    (version "0.2.3")
    (source
     (mobilizon-reshare-origin
      version
      "0c4d24ihs4yz054h6qvdw1441bv01jba8paiqii2302az4ir4mwj"))))

(define-public mobilizon-reshare-0.3.0
  (package (inherit mobilizon-reshare-0.2.2)
    (name "mobilizon-reshare")
    (version "0.3.0")
    (source
     (mobilizon-reshare-origin
      version
      "0p6y5jjhqdc4l7n75scibc72rabqpigcmglqydwvly52gr2qw9mw"))
    (native-inputs (package-native-inputs mobilizon-reshare-0.2.0))
    (propagated-inputs
       (list (patch-for-mobilizon-reshare-0.3 python-aerich)
             python-aiosqlite
             python-appdirs
             python-arrow
             python-beautifulsoup4
             python-click-8.0
             (patch-for-mobilizon-reshare-0.3 dynaconf)
             (patch-for-mobilizon-reshare-0.3 python-facebook-sdk)
             python-jinja2-3.0
             python-markdownify
             (patch-for-mobilizon-reshare-0.3 python-requests-2.26)
             (patch-for-mobilizon-reshare-0.3 python-tweepy)
             (patch-for-mobilizon-reshare-0.3 python-tortoise-orm-0.18.1)))))

(define-public mobilizon-reshare-0.3.1
  (package (inherit mobilizon-reshare-0.3.0)
    (name "mobilizon-reshare")
    (version "0.3.1")
    (source
     (mobilizon-reshare-origin
      version
      "1lhb2m0a0fw3lz8lj0hr8a2jgizvp73z8lx85hxjag1z753vhr3m"))
    (arguments
     (substitute-keyword-arguments (package-arguments mobilizon-reshare-0.3.0)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'install 'install-completion-scripts
              (lambda _
                (copy-recursively "etc" (string-append #$output "/etc"))))))))))

(define-public mobilizon-reshare-0.3.2
  (package (inherit mobilizon-reshare-0.3.1)
    (name "mobilizon-reshare")
    (version "0.3.2")
    (source
     (mobilizon-reshare-origin
      version
      "11dr3xglnrwdmqjinn1jl3bdqiqpzbij1vyn6vj16r5fx2g8gbf5"))
    (propagated-inputs
       (modify-inputs (package-propagated-inputs mobilizon-reshare-0.3.1)
         (replace "python-jinja2" python-jinja2)))))

(define-public mobilizon-reshare
  mobilizon-reshare-0.3.2)
