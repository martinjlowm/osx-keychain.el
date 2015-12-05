(defun security-args (type account server)
  "Build a list of arguments for `security', the keychain application of OS X."
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
  (let ((password-line
         (first
          (apply 'process-lines
                 (append '("security")
                         (security-args type account server))))))
    (string-match "password: \"\\(.*\\)\"" password-line)
    (match-string 1 password-line)))


(defun find-keychain-internet-password (account server)
  (find-keychain-password "internet" account server))

(defun find-keychain-generic-password (account server)
  (find-keychain-password "generic" account server))
