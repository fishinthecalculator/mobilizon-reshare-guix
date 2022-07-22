(define-module (mobilizon-reshare dependencies)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix transformations)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system python)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages check)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages openstack)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages time))

(define-public python-iso8601-0.1.13
  (package (inherit python-iso8601)
   (version "0.1.13")
   (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "iso8601" version))
       (sha256
         (base32 "1cgfj91khil4ii5gb8s6nxwm73vx7hqc2k79dd9d8990ylmc5ppp"))))))

(define-public python-idna-2.10
  (package (inherit python-idna)
   (version "2.10")
   (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "idna" version))
       (sha256
         (base32 "1xmk3s92d2vq42684p61wixfmh3qpr2mw762w0n6662vhlpqf1xk"))))))

(define-public python-requests-2.25
 (let ((patch
        (package-input-rewriting/spec `(("python-idna" . ,(const python-idna-2.10))
                                        ("python-iso8601" . ,(const python-iso8601-0.1.13))))))
   (patch
    (package (inherit python-requests)
     (version "2.25.1")
     (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "requests" version))
        (sha256
          (base32 "015qflyqsgsz09gnar69s6ga74ivq5kch69s4qxz3904m7a3v5r7"))))
     (propagated-inputs
       (modify-inputs (package-propagated-inputs python-requests)
        (append python-chardet)))))))

(define-public python-facebook-sdk
  (package
    (name "python-facebook-sdk")
    (version "3.1.0")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "facebook-sdk" version))
        (sha256
          (base32 "138grz0n6plzdqgi4h6hhszf58bsvx9v76cwj51g1nd3kvkd5g6a"))))
    (build-system python-build-system)
    (propagated-inputs `(("python-requests" ,python-requests)))
    (home-page "https://facebook-sdk.readthedocs.io")
    (synopsis
      "Facebook Graph API client in Python")
    (description
      "This client library is designed to support the Facebook Graph API and
the official Facebook JavaScript SDK, which is the canonical way to implement
Facebook authentication.")
    (license license:asl2.0)))

(define-public python-facebook-sdk.git
  (let ((version (package-version python-facebook-sdk))
        (revision "0")
        (commit "3fa89fec6a20dd070ccf57968c6f89256f237f54"))
    (package (inherit python-facebook-sdk)
     (name "python-facebook-sdk.git")
     (version (git-version version revision commit))
     (source
      (origin
        (method git-fetch)
        (uri
         (git-reference
          (url "https://github.com/mobolic/facebook-sdk")
          (commit commit)))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "0vayxkg6p8wdj63qvzr24dj3q7rkyhr925b31z2qv2mnbas01dmg"))))
     (arguments
      `(#:tests? #false)))))

(define-public python-tweepy-4.1
 (package (inherit python-tweepy)
  (version "4.1.0")
  (source
   (origin
     (method url-fetch)
     (uri (pypi-uri "tweepy" version))
     (sha256
       (base32 "04fmlw6a89r5s9ln5jb3kl2hcn5wdycmi0wbpb4l6w5cwn6r7ql8"))))
  (arguments
   `(#:tests? #f))))

(define-public python-requests-2.26
 (package (inherit python-requests)
  (version "2.26.0")
  (source
   (origin
     (method url-fetch)
     (uri (pypi-uri "requests" version))
     (sha256
       (base32 "19q73fq7hip7b74fwls3p9x6zwvfwqcwpn6kha3zsgvrrzw5iamq"))))
  (propagated-inputs
    (modify-inputs (package-propagated-inputs python-requests)
     (replace "python-iso8601" python-iso8601-0.1.13)))))

(define-public patch-with-requests-2.26
  (package-input-rewriting/spec `(("python-iso8601" . ,(const python-iso8601-0.1.13))
                                  ("python-requests" . ,(const python-requests-2.26)))))

;; This comes from Guix commit 812f2a185a82beb9dbd6af499a516a49d722932d
(define-public python-jinja2-3.0
  (package (inherit python-jinja2)
    (name "python-jinja2")
    (version "3.0.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "Jinja2" version))
       (sha256
        (base32
         "197ms1wimxql650245v63wkv04n8bicj549wfhp51bx68x5lhgvh"))))
    (build-system python-build-system)
    (arguments
     '(#:phases (modify-phases %standard-phases
                  (replace 'check
                    (lambda* (#:key tests? #:allow-other-keys)
                      (if tests?
                          (invoke "pytest" "-vv")
                          (format #t "test suite not run~%")))))))
    (native-inputs
     (list python-pytest))
    (propagated-inputs
     (list python-markupsafe))))

;; This comes from Guix commit ef347195278eb160ec725bbdccf71d67c0fa4271
(define-public python-asynctest-from-the-past
  (package
    (name "python-asynctest")
    (version "0.13.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "asynctest" version))
       (sha256
        (base32
         "1b3zsy7p84gag6q8ai2ylyrhx213qdk2h2zb6im3xn0m5n264y62"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f))
    (home-page "https://github.com/Martiusweb/asynctest")
    (synopsis "Extension of unittest for testing asyncio libraries")
    (description
     "The package asynctest is built on top of the standard unittest module
and cuts down boilerplate code when testing libraries for asyncio.")
    (license license:asl2.0)))

(define-public python-pytest-asyncio-0.15
  (package (inherit python-pytest-asyncio)
    (name "python-pytest-asyncio")
    (version "0.15.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "pytest-asyncio" version))
       (sha256
        (base32
         "0vrzsrg3j1cfd57m0b3r5xf87rslgcs42jya346mdg9bc6wwwr15"))))
    (arguments
     `(#:tests? #f))))

(define-public python-ddlparse
  (package
    (name "python-ddlparse")
    (version "1.10.0")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "ddlparse" version))
        (sha256
          (base32 "1nh8m6rxslwk05daxshxmgk41qfp18yynydba49b13l4m8dnh634"))))
    (build-system python-build-system)
    (arguments
      ;; Tests depend on network access.
      `(#:tests? #false))
    (propagated-inputs (list python-pyparsing))
    (home-page "http://github.com/shinichi-takii/ddlparse")
    (synopsis "DDL parase and Convert to BigQuery JSON schema")
    (description "DDL parase and Convert to BigQuery JSON schema")
    (license #f)))

(define-public python-pypika-tortoise-0.1.3
  (package (inherit python-pypika-tortoise)
   (version "0.1.3")
   (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "pypika-tortoise" version))
       (sha256
         (base32 "066jb88f3hk42sks69gv6w7k5irf6r0ssbly1n41a3pb19p2vpzc"))))))

(define-public python-tortoise-orm-0.18.1
  (package (inherit python-tortoise-orm)
   (version "0.18.1")
   (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "tortoise-orm" version))
       (sha256
         (base32 "1c8xq3620z04i1yp8n6bfshi98qkjjydkbs3zld78a885p762wsk"))))
   (propagated-inputs
        (list python-aiomysql
              python-aiosqlite
              python-asyncmy
              python-asyncpg
              python-ciso8601
              python-iso8601-0.1.13
              python-pypika-tortoise-0.1.3
              python-pytz
              python-rapidjson
              python-uvloop))))

(define-public python-aerich
 (package
  (name "python-aerich")
  (version "0.6.3")
  (source
   (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/tortoise/aerich")
          (commit (string-append "v" version))))
    (file-name (git-file-name name version))
    (sha256
     (base32
      "1ndkl8vvn6bxh19s26k3p5mlk1sk4ziw73c07av08va6cfp5ln0j"))
    (modules '((guix build utils)))
    (snippet
     #~(begin
         (let ((bash (string-append #$bash "/bin/bash"))
               (gzip (string-append #$gzip "/bin/gzip"))
               (poetry (string-append #$poetry "/bin/poetry"))
               (tar (string-append #$tar "/bin/tar")))
           ;; This is an hack to obtain poetry's setup.py.
           (setenv "POETRY_VIRTUALENVS_CREATE" "false")
           (invoke poetry "build" "-f" "sdist")
           (invoke bash "-c" (string-append "cd dist && " gzip " -cd ./*-`" poetry " version -s`.tar.gz > out.tar"))
           (invoke bash "-c"
                   (string-append
                    tar " --wildcards -xvf dist/out.tar -O '*/setup.py' > setup.py"))
           ;; Reduce source size.
           (delete-file-recursively "dist"))))))
  (build-system python-build-system)
  (native-inputs
   (list python-bandit
         python-cryptography
         python-isort
         python-pytest
         python-pytest-asyncio
         python-pytest-mock
         python-pytest-xdist))
  (propagated-inputs
   (list python-asyncmy
         python-asyncpg
         python-click
         python-ddlparse
         python-dictdiffer
         python-pydantic
         python-tomlkit
         python-tortoise-orm))
  (home-page "https://github.com/tortoise/aerich")
  (synopsis "Database migrations tool for Tortoise ORM (Object Relational
Mapper)")
  (description
   "This package provides @code{aerich}, a Python database migrations tool
for Tortoise ORM (Object Relational Mapper).  It can be used both
programmatically or as a standalone CLI application.")
  (license license:asl2.0)))

(define-public python-pytest-tornado5
  (package
    (name "python-pytest-tornado5")
    (version "2.0.0")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "pytest-tornado5" version))
        (sha256
          (base32 "0qb62jw2w0xr6y942yp0qxiy755bismjfpnxaxjjm05gy2pymr8d"))))
    (build-system python-build-system)
    (propagated-inputs (list python-pytest python-tornado))
    (home-page "https://github.com/vidartf/pytest-tornado")
    (synopsis
      "Fixtures and markers to simplify testing of Tornado applications")
    (description
      "This package provides a @code{py.test} plugin providing fixtures and markers to
simplify testing of asynchronous tornado applications.")
    (license license:asl2.0)))

(define-public python-rethinkdb
  (package
    (name "python-rethinkdb")
    (version "2.4.8")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "rethinkdb" version))
        (sha256
          (base32 "1vmap0la5j8xpigyp5bqph9cb6dskyw76y37n3vb16l9rlmsfxcz"))))
    (build-system python-build-system)
    (arguments
     `(#:tests? #f))
    (propagated-inputs (list python-six))
    (home-page "https://github.com/RethinkDB/rethinkdb-python")
    (synopsis "Python driver library for the RethinkDB database server.")
    (description "Python driver library for the RethinkDB database server.")
    (license #f)))

(define-public python-apscheduler
  (package
    (name "python-apscheduler")
    (version "3.8.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "APScheduler" version))
        (sha256
          (base32 "0m93bz9qpw6iwhay68bwljjcfyzcbh2rq0lc2yp4iamxrzml9wsw"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               ;; FIXME: Currently python-kazoo fails to build.
               (delete-file "tests/test_jobstores.py")
               (invoke "pytest")))))))
    (propagated-inputs
      (list python-pytz
            python-setuptools
            python-six
            python-tzlocal))
    (native-inputs
      (list python-mock
            python-pyqt
            python-twisted
            python-gevent
            python-setuptools-scm
            python-sqlalchemy
            python-redis
            python-pymongo
            python-rethinkdb
            python-pytest
            python-pytest-asyncio
            python-pytest-cov
            python-pytest-tornado5))
    (home-page "https://github.com/agronholm/apscheduler")
    (synopsis "In-process task scheduler with Cron-like capabilities")
    (description "In-process task scheduler with Cron-like capabilities")
    (license license:expat)))

(define-public python-apscheduler-for-telegram-bot
  (package (inherit python-apscheduler)
   (version "3.6.3")
   (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "APScheduler" version))
       (sha256
         (base32 "0i72qpqgrgq6bb9vwsac46m7bqb6mq92g5nf2gydmfvgxng25d9v"))))))

(define-public python-telegram-bot
  (package
    (name "python-telegram-bot")
    (version "13.10")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "python-telegram-bot" version))
        (sha256
          (base32 "0ghyq044s0zi67hxwxdjjfvh37wr86pi5kmpq7harx11311mbifj"))))
    (build-system python-build-system)
    (arguments
     ;; FIXME: Most tests require network access. Some of them can
     ;; be run from the git repository but many still fail due
     ;; to vendoring of a seemingly heavily patched urllib3.
     `(#:tests? #f))
    (native-inputs
     (list python-beautifulsoup4
           python-pytest
           python-flaky))
    (propagated-inputs
      (list python-apscheduler-for-telegram-bot
            python-cachetools
            python-certifi
            python-pytz
            python-tornado-6))
    (home-page "https://python-telegram-bot.org/")
    (synopsis "We have made you a wrapper you can't refuse")
    (description "We have made you a wrapper you can't refuse")
    (license #f)))

(define-public python-tortoise-orm-0.17
  (package (inherit python-tortoise-orm)
   (version "0.17.8")
   (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "tortoise-orm" version))
       (sha256
         (base32 "1gzgiypln7lck3p95vk3i8rdx1bjbmmlcpb8xpba8cjdjvlj0l0z"))))
   (arguments
    `(#:tests? #f))
   (propagated-inputs
    (modify-inputs (package-propagated-inputs python-tortoise-orm)
     (replace "python-iso8601" python-iso8601-0.1.13)))))

(define-public python-click-8.0
 (package (inherit python-click)
  (version "8.0.3")
  (source
   (origin
     (method url-fetch)
     (uri (pypi-uri "click" version))
     (sha256
       (base32 "0nybbsgaff8ihfh74nhmng6qj74pfpg99njc7ivysphg0lmr63j1"))))))

(define-public click-8-instead-of-click-7
  (package-input-rewriting/spec `(("python-click" . ,(const python-click-8.0)))))

(define-public patch-for-mobilizon-reshare-0.2.0
  (package-input-rewriting/spec `(("python-idna" . ,(const python-idna-2.10))
                                  ("python-iso8601" . ,(const python-iso8601-0.1.13))
                                  ("python-requests" . ,(const python-requests-2.25))
                                  ("python-tortoise-orm" . ,(const python-tortoise-orm-0.18.1)))))

(define-public patch-for-mobilizon-reshare-0.2.2
  (package-input-rewriting/spec `(("python-idna" . ,(const python-idna-2.10))
                                  ("python-iso8601" . ,(const python-iso8601-0.1.13))
                                  ("python-requests" . ,(const python-requests-2.25))
                                  ("python-click" . ,(const python-click-8.0)))))

(define-public patch-for-mobilizon-reshare-0.3
  (package-input-rewriting/spec `(("python-iso8601" . ,(const python-iso8601-0.1.13))
                                  ("python-tortoise-orm" . ,(const python-tortoise-orm-0.18.1))
                                  ("python-requests" . ,(const python-requests-2.26))
                                  ("python-click" . ,(const python-click-8.0)))))
