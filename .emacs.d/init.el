(setq gc-cons-threshold (* 100 1000 1000)) ;; 100MB

(defun qucchia/display-startup-time ()
  "Send a message describing how long it took Emacs to start up."
  (message "Emacs loaded in %s with %d garbage collections."
    (format "%.2f seconds"
    (float-time
      (time-subtract after-init-time before-init-time)))
  gcs-done))

(add-hook 'emacs-startup-hook #'qucchia/display-startup-time)

;; Initialise package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialise use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-verbose t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results nil)
  :config
  (auto-package-update-maybe))

(setq inhibit-startup-message t) ; Start up on a blank screen instead of the startup message

(scroll-bar-mode -1) ; Disable visible scrollbar
(tool-bar-mode -1) ; Disable toolbar
(tooltip-mode -1) ; Disable tooltips
(set-fringe-mode 50) ; Add margins
(menu-bar-mode -1) ; Disable menubar

;; Set up visible bell
(setq visible-bell t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                lsp-treemacs-generic-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(column-number-mode)
(global-display-line-numbers-mode t)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(set-face-attribute 'default nil :font "Source Code Pro" :height 120)
(set-face-attribute 'fixed-pitch nil :font "Source Code Pro" :height 120)
(set-face-attribute 'variable-pitch nil :font "DejaVu sans" :height 120 :weight 'regular)

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package nord-theme
  :init (load-theme 'nord t))

;; (use-package doom-themes)

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 30)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-height 10))

(use-package ivy-rich
  :after (counsel ivy)
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(defun qucchia/uri-encode (string)
  "Encode STRING to URI (currently not working."
  string)

(defun qucchia/set-keymap ()
  "Set my custom keymap."
  (interactive)
  (start-process-shell-command "xmodmap" nil
    "xmodmap ~/.dotfiles/layout/.Xmodmap"))

(defun qucchia/get-password (name)
  "Retrieve the password NAME from pass and copies it to the clipboard."
  (interactive (list (read-string "Password name: ")))
  (start-process-shell-command "pass" nil
  (string-join
    (list
      "pass -c "
      name
      " | xclip -selection clipboard"))))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

(use-package general
  :after evil
  :config
  (general-create-definer qucchia/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (qucchia/leader-keys
    
    "b"   '(:ignore t :which-key "bookmark")
    
    "bc"  '(:ignore t :which-key "classroom")
    "bca" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/h"))
            :which-key "english")
    "bcc" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/Mzg5NzM5MTU1NzE1"))
            :which-key "catalan")
    "bcd" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/MTY0ODg2NDY5MjAx"))
            :which-key "dibuix")
    "bce" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/Mzg5NzcxMzA1ODQ1"))
            :which-key "spanish")
    "bcf" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/Mzg5OTkwODAzNjYz"))
            :which-key "p.e.")
    "bcl" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/MzIwODUyMDAyNTQw"))
            :which-key "philosophy")
    "bcm" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/MzIwNjgyODcyMDM4"))
            :which-key "cmc")
    "bcq" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/MzkwMjkzNzQ0Mjc3"))
            :which-key "maths")
    "bct" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/MzkwMjMwODAxMTM4"))
            :which-key "technology")
    "bcu" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/MzU2OTczMzczMDU3"))
            :which-key "tutoria")
    "bcy" '((lambda ()
              (interactive)
              (browse-url "https://classroom.google.com/u/1/c/MzIwNjE5OTE2ODMz"))
            :which-key "physics")
    
    "bd"  '((lambda ()
              (interactive)
              (browse-url "https://discord.com/app"))
            :which-key "discord")
    
    "bf"  '(:ignore t :which-key "firefox")
    "bfp" '((lambda ()
              (interactive)
              (browse-url "about:preferences"))
            :which-key "preferences")
    
    "bg"  '((lambda ()
              (interactive)
              (browse-url "https://codeberg.org"))
            :which-key "codeberg")
    "bm"  '((lambda ()
              (interactive)
              (browse-url "https://moodle.ins-mediterrania.cat/login/index.php"))
            :which-key "moodle")
    "bw"  '((lambda ()
              (interactive)
              (browse-url "https://web.whatsapp.com"))
            :which-key "whatsapp")
    "by"  '((lambda ()
              (interactive)
              (browse-url "https://www.youtube.com"))
            :which-key "youtube")
    
    "c"   '(org-capture :which-key "capture")
    
    "d"  '(:ignore t :which-key "directory")
    "d~" '((lambda ()
             (interactive)
             (dired "~/"))
           :which-key "home")
    "d." '((lambda ()
             (interactive)
             (dired dotfiles-folder))
           :which-key "dotfiles")
    "dd" '((lambda ()
             (interactive)
             (dired "~/Downloads"))
           :which-key "downloads")
    "dD" '((lambda ()
             (interactive)
             (dired "~/Documents"))
           :which-key "documents")
    "dm" '((lambda ()
             (interactive)
             (dired "~/Music"))
           :which-key "music")
    "dp" '((lambda ()
             (interactive)
             (dired "~/Projects"))
           :which-key "projects")
    
    "C-h" '(org-shiftleft :which-key "shift left")
    "C-j" '(org-shiftdown :which-key "shift down")
    "C-k" '(org-shiftup :which-key "shift up")
    "C-l" '(org-shiftright :which-key "shift right")
    
    "o"     '(:ignore t :which-key "open")
    "oa"    '(org-agenda :which-key "agenda")
    "oe"    '(emms :which-key "emms")
    "o C-e" '(eshell :which-key "eshell")
    "of"    '((lambda ()
                (interactive)
                (start-process-shell-command "firefox" nil "firefox"))
              :which-key "firefox")
    "oi"    '(ibuffer :which-key "ibuffer")
    "os"    '(shell :which-key "shell")
    "ot"    '(term :which-key "term")
    "ov"    '(vterm :which-key "vterm")
    
    
    "m"  '(:ignore t :which-key "mail")
    "mc" '(mu4e-compose-new :which-key "compose")
    "mm" '(mu4e :which-key "open")
    "ms" '(mu4e-update-mail-and-index :which-key "sync")
    
    "k"   '(counsel-descbinds :which-key "keybindings")
    "p"   '(emms-pause :which-key "pause music")
    "C-p" '(qucchia/get-password :which-key "password")
    "t"   '(:ignore t :which-key "toggle")
    "te"  '(emms-mode-line-toggle :which-key "emms modeline")
    "tt"  '(counsel-load-theme :which-key "choose theme")
    "ts"  '(hydra-text-scale/body :which-key "scale text")
    
    "s"  '(:ignore t :which-key search)
    "sc" '((lambda (term)
             (interactive (list (qucchia/uri-encode (read-string "DIEC "))))
             (browse-url (string-join (list "https://dlc.iec.cat/Results?DecEntradaText=" term))))
           :which-key "diec")
    "sd" '((lambda (term)
             (interactive (list (qucchia/uri-encode (read-string "DuckDuckGo "))))
             (browse-url (string-join (list "https://duckduckgo.com/?q=" term))))
           :which-key "duckduckgo")
    "sm" '((lambda (term)
             (interactive (list (qucchia/uri-encode (read-string "MDN "))))
             (browse-url (string-join (list "https://developer.mozilla.org/en-US/search?q=" term))))
           :which-key "mdn")
    "sr" '((lambda (term)
             (interactive (list (qucchia/uri-encode (read-string "RAE "))))
             (browse-url (string-join (list "https://dle.rae.es/" term))))
           :which-key "rae")
    "ss" '((lambda (term)
             (interactive (list (qucchia/uri-encode (read-string "StartPage "))))
             (browse-url (string-join (list "https://www.startpage.com/do/dsearch?query=" term))))
           :which-key "startpage")
    "sw" '((lambda (term)
             (interactive (list (qucchia/uri-encode (read-string "SwissCows "))))
             (browse-url (string-join (list "https://swisscows.com/web?query=" term))))
           :which-key "swisscows")
    "sy" '((lambda (term)
             (interactive (list (qucchia/uri-encode (read-string "YouTube "))))
             (browse-url (string-join (list "https://www.youtube.com/results?search_query=" term))))
           :which-key "youtube")
    
    "u"   '(browse-url :which-key "url")
    "x"   '(qucchia/set-keymap :which-key "set keymap")
    "y"   '(counsel-yank-pop :which-key "yank"))

  (general-define-key
   "C-M-n" 'counsel-switch-buffer
   "<pause>" 'emms-pause))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(defun qucchia/org-mode-setup ()
  "Setup Org mode."
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun qucchia/org-font-setup ()
  "Setup Org mode fonts."
  ;; Replace list hypens with dots
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "DejaVu sans" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed pitch in Org mode appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil :inherit '(org-hide fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . qucchia/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '("~/Documents/life/Tasks.org"
          ;; "~/Documents/life/Habits.org"
          "~/Documents/life/Birthdays.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
        '(("Archive.org" :maxlevel . 1)
          ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
        '((:startgroup)
                                        ;Put mutually exclusive tags here
          (:endgroup)
          ("@errand" . ?E)
          ("@home" . ?H)
          ("@work" . ?W)
          ("@school" . ?S)
          ("@coding" . ?C)
          ("@personal" . ?P)
          ("agenda" . ?a)
          ("planning" . ?p)
          ("note" . ?n)
          ("reading" . ?r)
          ("organisation" . ?o)
          ("spiritual" . ?s)
          ("setup" . ?t)
          ("health" . ?h)
          ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-deadline-warning-days 7)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))
            (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

          ("n" "Next Tasks"
           ((todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))))

          ("W" "Work Tasks" tags-todo "+@school")

          ;; Low-effort next actions
          ("e" tags-todo "+TODO=\"NEXT\"+Effort<156+Effort>0"
           ((org-agenda-overriding-header "Low Effort Tasks")
            (org-agenda-max-todos 20)
            (org-agenda-files org-agenda-files)))

          ("w" "Workflow Status"
           ((todo "WAIT"
                  ((org-agenda-overriding-header "Waiting on External")
                   (org-agenda-files org-agenda-files)))
            (todo "REVIEW"
                  ((org-agenda-overriding-header "In Review")
                   (org-agenda-files org-agenda-files)))
            (todo "PLAN"
                  ((org-agenda-overriding-header "In Planning")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "BACKLOG"
                  ((org-agenda-overriding-header "Project Backlog")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "READY"
                  ((org-agenda-overriding-header "Ready for Work")
                   (org-agenda-files org-agenda-files)))
            (todo "ACTIVE"
                  ((org-agenda-overriding-header "Active Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "COMPLETED"
                  ((org-agenda-overriding-header "Completed Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "CANC"
                  ((org-agenda-overriding-header "Cancelled Projects")
                   (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
        `(("t" "Tasks / Projects")
          ("tt" "Task" entry (file+olp "~/Documents/life/Tasks.org" "Inbox")
           "* TODO %?\n %U\n %a\n %i" :empty-lines 1)
          ("ts" "Clocked Entry Subtask" entry (clock)
           "* TODO %?\n %U\n %a\n %i" :empty-lines 1)

          ("j" "Journal Entries")
          ("jj" "Journal" entry
           (file+olp+datetree "~/Documents/life/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)
          ("jm" "Meeting" entry
           (file+olp+datetree "~/Documents/life/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

          ("w" "Workflows")
          ("we" "Checking Email" entry (file+olp+datetree "~/Documents/life/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

          ("m" "Metrics Capture")
          ("my" "Typing Speed" table-line (file+headline "~/Documents/life/Metrics.org" "Typing Speed")
           "| %U | %^{Speed} | %^{Accuracy} | %^{Program} | %^{Notes} |" :kill-buffer t)))

  (qucchia/org-font-setup))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun qucchia/org-visual-mode-fill ()
  "Setup Org mode visual fill."
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . qucchia/org-visual-mode-fill))

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (js . t)
     (shell . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("js" . "src js"))
  (add-to-list 'org-structure-template-alist '("conf" . "src conf")))

(defun qucchia/org-babel-tangle-config ()
  "Tangle dotfiles on save."
  (when (string-prefix-p (expand-file-name "~/.dotfiles/")
                       (buffer-file-name))
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda ()
  (add-hook 'after-save-hook #'qucchia/org-babel-tangle-config)))

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package flycheck
  :init (global-flycheck-mode)
  (add-hook 'after-init-hook #'global-flycheck-mode))

(defun qucchia/lsp-mode-setup ()
  "Setup LSP."
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((html-mode . lsp-deferred)
    (js2-mode . lsp-deferred)
    (json-mode . lsp-deferred)
    (typescript-mode . lsp-deferred)
    (php-mode . lsp-deferred)
    (lsp-mode . qucchia/lsp-mode-setup))
  :init
  (setq lsp-keymap-prefix "C-c l")
  (setq read-process-output-max (* 1024 1024)) ;; 1MB
  :config
  (lsp-enable-which-key-integration t))

(add-to-list 'auto-mode-alist '("\\.html\\'" . html-mode))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :config (lsp-treemacs-sync-mode 1)
  :commands lsp-treemacs-errors-list)

(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)

;; (use-package dap-mode :after lsp-mode)

(use-package prettier)
(use-package prettier-js
  :after prettier)
(add-hook 'js2-mode-hook 'prettier-js-mode)
(add-hook 'typescript-mode-hook 'prettier-mode)

(use-package lua-mode
  :mode "\\.lua\\'")

(use-package js2-mode
  :mode "\\.js\\'"
  :config (setq js-indent-level 2))

(use-package json-mode :mode "\\.json\\'")

(use-package typescript-mode
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 2))

(use-package php-mode :mode "\\.php\\'")

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-acion #'projectile-dired))

(use-package counsel-projectile
  :init (counsel-projectile-mode))

(use-package magit
  :commands (magit magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :bind (("C-x C-j" . dired-jump))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  (setq dired-open-extensions '(("png" . "display"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package diredfl
  :hook (dired-mode . diredfl-mode))

(use-package term
  :defer t
  :config
  (setq explicit-shell-file-name "bash")
  (setq term-prompt-regexp "^\\w+@\\w+:[^#$%>\n]* $ *"))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

(use-package exec-path-from-shell
  :after eshell
  :config (exec-path-from-shell-initialize))

(use-package eshell-git-prompt
  :after eshell)

(defun qucchia/setup-eshell ()
  "Setup eshell."
  ;; Save command history
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size 10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell
  :hook (eshell-first-time-mode . qucchia/setup-eshell)
  :config
  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(use-package mu4e
  :ensure nil
  :commands (mu4e)
  :load-path "/usr/share/emacs/site-lisp/mu4e/"
  ;; :defer 20
  :config
  ;; This is set to 't' to avoid mail syncing issues when using mbsync
  (setq mu4e-change-filenames-when-moving t)

  ;; Refresh mail using isync every 10 minutes
  (setq mu4e-update-interval (* 10 60))
  (setq mu4e-get-mail-command "mbsync -a")
  (setq mu4e-maildir "~/Mail/")

  (setq mu4e-contexts
        (list
         
         (make-mu4e-context
          :name "Personal"
          :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/Personal" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "yijods@gmail.com")
                  (user-full-name . "qucchia")
                  (mu4e-compose-signature . "qucchia")
                  (mu4e-drafts-folder . "/Personal/[Gmail]/Drafts")
                  (mu4e-sent-folder . "/Personal/[Gmail]/Sent Mail")
                  (mu4e-refile-folder . "/Personal/[Gmail]/All Mail")
                  (mu4e-trash-folder . "/Personal/[Gmail]/Trash")
                  (mu4e-maildir-shortcuts
                   (:maildir "/Personal/Inbox"             :key ?i)
                   (:maildir "/Personal/[Gmail]/Sent Mail" :key ?s)
                   (:maildir "/Personal/[Gmail]/Trash"     :key ?b)
                   (:maildir "/Personal/[Gmail]/Drafts"    :key ?d)
                   (:maildir "/Personal/[Gmail]/All Mail"  :key ?a))))
         
         
         (make-mu4e-context
          :name "School"
          :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/School" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "timothydavid.skipper@alumnat.ins-mediterrania.cat")
                  (user-full-name . "Timothy D. Skipper")
                  (mu4e-compose-signature . "Timothy D. Skipper")
                  (mu4e-drafts-folder . "/School/[Gmail]/Drafts")
                  (mu4e-sent-folder . "/School/[Gmail]/Sent Mail")
                  (mu4e-refile-folder . "/School/[Gmail]/All Mail")
                  (mu4e-trash-folder . "/School/[Gmail]/Trash")
                  (mu4e-maildir-shortcuts
                   (:maildir "/School/Inbox"             :key ?i)
                   (:maildir "/School/[Gmail]/Sent Mail" :key ?s)
                   (:maildir "/School/[Gmail]/Trash"     :key ?b)
                   (:maildir "/School/[Gmail]/Drafts"    :key ?d)
                   (:maildir "/School/[Gmail]/All Mail"  :key ?a))))
         
         
         (make-mu4e-context
          :name "Development"
          :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/Development" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "qucchia0@gmail.com")
                  (user-full-name . "qucchia")
                  (mu4e-compose-signature . "qucchia")
                  (mu4e-drafts-folder . "/Development/[Gmail]/Drafts")
                  (mu4e-sent-folder . "/Development/[Gmail]/Sent Mail")
                  (mu4e-refile-folder . "/Development/[Gmail]/All Mail")
                  (mu4e-trash-folder . "/Development/[Gmail]/Trash")
                  (mu4e-maildir-shortcuts
                   (:maildir "/Development/Inbox"             :key ?i)
                   (:maildir "/Development/[Gmail]/Sent Mail" :key ?s)
                   (:maildir "/Development/[Gmail]/Trash"     :key ?b)
                   (:maildir "/Development/[Gmail]/Drafts"    :key ?d)
                   (:maildir "/Development/[Gmail]/All Mail"  :key ?a))))
         
         
         (make-mu4e-context
          :name "Work"
          :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/Work" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "timothydskipper@gmail.com")
                  (user-full-name . "Timothy D. Skipper")
                  (mu4e-compose-signature . "Timothy D. Skipper")
                  (mu4e-drafts-folder . "/Work/[Gmail]/Drafts")
                  (mu4e-sent-folder . "/Work/[Gmail]/Sent Mail")
                  (mu4e-refile-folder . "/Work/[Gmail]/All Mail")
                  (mu4e-trash-folder . "/Work/[Gmail]/Trash")
                  (mu4e-maildir-shortcuts
                   (:maildir "/Work/Inbox"             :key ?i)
                   (:maildir "/Work/[Gmail]/Sent Mail" :key ?s)
                   (:maildir "/Work/[Gmail]/Trash"     :key ?b)
                   (:maildir "/Work/[Gmail]/Drafts"    :key ?d)
                   (:maildir "/Work/[Gmail]/All Mail"  :key ?a))))
         ))

  ;; Sending mail
  (setq smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 465
        smtpmail-stream-type 'ssl
        message-send-mail-function 'smtpmail-send-it
        mu4e-compose-format-flowed t)

  (setq mu4e-bookmarks
        '((:name "Unread messages" :query "flag:unread AND NOT flag:trashed" :key ?u)
          (:name "All inboxes" :query "maildir:/^.*/Inbox/" :key ?i)
          (:name "Today's messages" :query "date:today..now" :key ?t)
          (:name "Last 7 days" :query "date:7d..now" :hide-unread t :key ?w)
          (:name "Messages with images" :query "mime:image/*" :key ?p))))

(setq dotfiles-folder "~/.dotfiles")
(setq dotfiles-org-files '("Emacs.org" "Desktop.org"))

(defun dotfiles-tangle-org-file (&optional org-file)
  "Tangles a single .org file relative to the path in the dotfiles folder."
  (interactive)
  (message "File: %s" org-file)
  ;; Suppress prompts and messages
  (let ((org-confirm-babel-evaluate nil)
        (message-log-max nil)
        (inhibit-message t))
    (org-babel-tangle-file (expand-file-name org-file dotfiles-folder))))

(defun dotfiles-tangle-org-files ()
  "Tangles all of the .org dotfiles."
  (interactive)
  (dolist (org-file dotfiles-org-files)
    (dotfiles-tangle-org-file org-file))
  (message "Dotfiles are up to date!"))

(use-package emms
  :config
  (emms-all)
  (emms-default-players)
  :custom
  (emms-source-file-default-directory "~/Music/"))

(defun qucchia/lookup-password (&rest keys)
  "Lookup password from auth source."
  (let ((result (apply #'auth-source-search keys)))
   (if result
       (funcall (plist-get (car result) :secret))
     nil)))