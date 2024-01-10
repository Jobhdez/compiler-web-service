(in-package #:lambda-server)

;;; == server ===

(defvar *server*
  (make-instance 'hunchentoot:easy-acceptor
                 :port 4243))

(defun start-server ()
  (hunchentoot:start *server*))

(defun stop-server ()
  (hunchentoot:stop *server*))

;;; Launching in the browser:

;;; adopted from https://github.com/eudoxia0/trivial-open-browser, thank you
(defparameter +format-string+
  #+(or win32 mswindows windows)
  "explorer ~S"
  #+(or macos darwin)
  "open ~S"
  #-(or win32 mswindows macos darwin windows)
  "xdg-open ~S")

(defun open-browser (url)
  "Opens the browser to your target url"
  (uiop:run-program (format nil +format-string+ url)))

(defun launch ()
  (start-server)
  (uiop:run-program
   (format nil
           +format-string+
           "http://localhost:4243/compile?exp=(if (= 2 2) 2 3)")))
