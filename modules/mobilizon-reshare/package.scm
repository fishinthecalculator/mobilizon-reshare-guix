(define-module (mobilizon-reshare package)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix build-system python)
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
    (file-name (git-file-name "mobilizon-reshare" version))))

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
               (add-after 'unpack 'generate-setup.py
                (lambda _
                  ;; This hack is needed to get poetry's
                  ;; setup.py.
                  (setenv "POETRY_VIRTUALENVS_CREATE" "false")
                  (invoke "poetry" "build" "-f" "sdist")
                  (invoke "bash" "-c"
                          (string-join
                           `("tar" "--wildcards" "-xvf"
                             "dist/*-`poetry version -s`.tar.gz" "-O '*/setup.py'"
                             "> setup.py")
                           " "))))
               (add-after 'generate-setup.py 'prevent-versions-enforcing
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
           poetry
           python-pytest
           python-pytest-asyncio-0.15
           python-responses))
    (propagated-inputs
     (list python-aiosqlite
           python-appdirs
           python-arrow-1.1
           python-beautifulsoup4
           python-click
           dynaconf
           python-jinja2
           python-markdownify
           python-requests
           python-tortoise-orm))
    (home-page
     "https://github.com/Tech-Workers-Coalition-Italia/mobilizon-reshare")
    (synopsis
     "Publish Mobilizon events to your social networks")
    (description
     "This package provides a CLI application to publish your Mobilizon
events to your social media.")
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
               (add-after 'unpack 'generate-setup.py
                (lambda _
                  ;; This hack is needed to get poetry's
                  ;; setup.py.
                  (setenv "POETRY_VIRTUALENVS_CREATE" "false")
                  (invoke "poetry" "build" "-f" "sdist")
                  (invoke "bash" "-c"
                          (string-join
                           `("tar" "--wildcards" "-xvf"
                             "dist/*-`poetry version -s`.tar.gz" "-O '*/setup.py'"
                             "> setup.py")
                           " "))))
               (add-after 'generate-setup.py 'prevent-versions-enforcing
                 (lambda _
                   (substitute* "setup.py"
                     (("'install_requires': install_requires,") ""))))
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
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
             poetry
             python-pytest
             python-pytest-cov
             python-pytest-asyncio
             python-pytest-lazy-fixture
             python-responses))
    (propagated-inputs
     (list python-aerich
           python-aiosqlite
           python-appdirs
           python-arrow
           python-beautifulsoup4
           python-click
           dynaconf
           python-facebook-sdk.git
           python-jinja2
           python-markdownify
           python-requests
           python-telegram-bot
           python-tweepy
           python-tortoise-orm-0.18.1))))

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
     (modify-inputs (package-propagated-inputs mobilizon-reshare-0.2.0)
      (replace "python-click"
        python-click-8.0)
      (replace "python-jinja2"
        python-jinja2-3.0)
      (replace "python-aerich"
        (click-8-instead-of-click-7 python-aerich))
      (replace "dynaconf"
        (click-8-instead-of-click-7 dynaconf))
      (delete "python-facebook-sdk.git")
      (append (requests-2.25-instead-of-requests-2.26 python-facebook-sdk))
      (replace "python-requests" python-requests-2.25)
      (replace "python-tweepy"
        (requests-2.25-instead-of-requests-2.26 python-tweepy-4.1))))))

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
    (propagated-inputs
       (list (click-8-instead-of-click-7 python-aerich)
             python-aiosqlite
             python-appdirs
             python-arrow
             python-beautifulsoup4
             python-click-8.0
             (click-8-instead-of-click-7 dynaconf)
             python-facebook-sdk
             python-jinja2-3.0
             python-markdownify
             python-requests
             python-tweepy
             python-tortoise-orm-0.18.1))))

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


(define-public mobilizon-reshare
  mobilizon-reshare-0.3.1)
