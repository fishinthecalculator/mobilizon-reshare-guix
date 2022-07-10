(define-module  (mobilizon-reshare utils)
  #:use-module (guix inferior)
  #:use-module (guix channels)
  #:use-module (srfi srfi-1))   ;for 'first'

(define (make-channels hash)
  ;; This is the old revision from which we want to
  ;; extract a given package.
  (list (channel
         (name 'guix)
         (url "https://git.savannah.gnu.org/git/guix.git")
         (commit hash))))

(define (make-inferior hash)
  ;; An inferior representing the above revision.
  (inferior-for-channels (make-channels hash)))

(define-public (with-guix-version hash package-label)
 (first (lookup-inferior-packages (make-inferior hash) package-label)))
