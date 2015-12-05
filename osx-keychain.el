;;; osx-keychain.el --- Interface with the keychain of OS X

;;; Includes functions that interface with the security utility to look up
;;; internet- or generic passwords.

;;; This file not shipped as part of GNU Emacs.

;;; Commentary:

;; See documentation in README.md

;;; Code:
(defun security-args (type account server)
  "Build a list of arguments of TYPE, ACCOUNT and SERVER for security."
  (let ((version-string (shell-command-to-string "sw_vers -productVersion"))
        (args '()))
    (add-to-list 'args (concat "find-" type "-password") t)
    (when (string-match "\\([0-9]+\\)\\.\\([0-9]+\\)\\.\\([0-9]+\\)" version-string)
      (let ((major-version (string-to-number (match-string 1 version-string)))
            (minor-version (string-to-number (match-string 2 version-string)))
            (patch-version (string-to-number (match-string 3 version-string))))
        (when (= major-version 10)
          (if (<= minor-version 7)
              (add-to-list 'args "-w" t)
            (add-to-list 'args "-g" t)))))
    (add-to-list 'args "-a" t) (add-to-list 'args account t)
    (add-to-list 'args "-s" t) (add-to-list 'args server t)
    args))

(defun find-keychain-password (type account server)
  "Return the password fetched from security.
TYPE, ACCOUNT and SERVER is passed on to `security-args' to build
a list of required arguments for security."
  (let ((password-line
         (car (apply 'process-lines
                 (append '("security")
                         (security-args type account server))))))
    (string-match "password: \"\\(.*\\)\"" password-line)
    (match-string 1 password-line)))


(defun find-keychain-internet-password (account server)
  "Return an internet password given ACCOUNT and SERVER."
  (find-keychain-password "internet" account server))

(defun find-keychain-generic-password (account server)
  "Return a generic password given ACCOUNT and SERVER."
  (find-keychain-password "generic" account server))

(provide 'osx-keychain)
;;; osx-keychain.el ends here
