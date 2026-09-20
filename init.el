(setopt ring-bell-function 'ignore
        auto-save-default nil
        use-short-answers t
        scroll-conservatively 101
        display-line-numbers-type 'relative
        inhibit-startup-screen t
        make-backup-files nil
        create-lockfiles nil
        truncate-lines t
        delete-selection-mode t
        indent-tabs-mode nil
        require-final-newline t
        help-window-select t
        recentf-max-saved-items 200
        eldoc-idle-delay most-positive-fixnum
        global-auto-revert-non-file-buffers t
        split-height-threshold nil
        split-width-threshold 0
        custom-file (expand-file-name "custom.el" "~/.cache/emacs/"))

(when (file-exists-p custom-file)
  (load custom-file))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(electric-pair-mode +1)
(recentf-mode +1)
(fringe-mode 0)
(column-number-mode 1)
(xterm-mouse-mode 1)
(auto-save-visited-mode -1)
(which-key-mode 1)
(global-display-line-numbers-mode 1)
(global-auto-revert-mode 1)

(setopt mac-command-modifier 'meta
        mac-right-command-modifier 'super
        mac-option-modifier nil
        mac-right-option-modifier 'alt)

(setq xterm-extra-capabilities '(getSelection setSelection modifyOtherKeys))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))
      use-package-always-ensure t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(require 'use-package)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

(use-package undo-fu)

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-integration t)
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(evil-set-leader '(normal visual) (kbd "SPC"))
(evil-define-key '(normal visual) 'global (kbd "<leader>w") 'evil-write)
(evil-define-key '(normal visual) 'global (kbd "<leader>x") 'my/save-kill-buffer-and-window)
(evil-define-key '(normal visual) 'global (kbd "<leader>e") 'dired-jump)
(evil-define-key '(normal visual) 'global (kbd "<leader>d") 'dired-jump-other-window)
(evil-define-key '(normal visual) 'global (kbd "<leader>'") 'consult-ripgrep)
(evil-define-key '(normal visual) 'global (kbd "<leader>ff") 'find-file)
(evil-define-key '(normal visual) 'global (kbd "<leader>fp") 'project-switch-project)
(evil-define-key '(normal visual) 'global (kbd "<leader>fw") 'find-file-other-window)
(evil-define-key '(normal visual) 'global (kbd "<leader>fr") 'consult-recent-file)
(evil-define-key '(normal visual) 'global (kbd "<leader>bb") 'consult-buffer)
(evil-define-key '(normal visual) 'global
  (kbd "<leader>/") #'comment-line)
(evil-define-key 'normal 'global (kbd "gD") 'xref-find-definitions-other-window)

(remove-hook 'eldoc-display-functions #'eldoc-display-in-echo-area)

(add-to-list 'display-buffer-alist
             '("\\`\\*eldoc"
               (display-buffer-at-bottom)
               (window-height . 0.3)
               (body-function . select-window)))

(add-to-list 'display-buffer-alist
             '("\\`\\*Flymake diagnostics" nil
               (body-function . select-window)))

(add-to-list 'display-buffer-alist
             '("\\`\\*compilation\\*\\'" nil
               (body-function . select-window)))

(use-package evil-collection
  :after evil
  :init
  (setq evil-collection-setup-minibuffer t)
  (setq evil-collection-key-blacklist '("SPC"))
  :config
  (evil-collection-init))

(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

(use-package consult
  :config
  (dolist (name '("*Async-native-compile-log*" "*straight-process*" "*direnv*" "*Messages*" ))
    (add-to-list 'consult-buffer-filter (concat "\\`" (regexp-quote name) "\\'"))))

(use-package marginalia
  :hook (after-init . marginalia-mode))

(use-package avy
  :after evil
  :custom
  (avy-timeout-seconds 0.3)
  :config
  (evil-define-key 'normal 'global (kbd "s") 'avy-goto-char-timer))

(use-package corfu
  :config
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  :custom
  (corfu-auto t)
  (corfu-count 8)
  (corfu-auto-prefix 1)
  (corfu-auto-delay 0))

(use-package corfu-terminal :hook (corfu-mode . corfu-terminal-mode))

(use-package dired
  :ensure nil
  :after evil
  :config
  (evil-define-key 'normal dired-mode-map
    (kbd "o") #'dired-find-file
    (kbd "a")   #'dired-create-empty-file
    (kbd "A")   #'dired-create-directory))

(add-hook 'rust-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'eglot-format-buffer nil t)))

(define-derived-mode typst-mode text-mode "Typst")
(add-to-list 'auto-mode-alist '("\\.typ\\'" . typst-mode))

(use-package eglot
  :ensure nil
  :hook ((rust-mode . eglot-ensure)
         (typst-mode . eglot-ensure)
         (nix-mode . eglot-ensure)
         (tuareg-mode . eglot-ensure))
  :custom
  (eglot-autoshutdown t)
  :config
  (setq completion-category-overrides
        '((eglot (styles basic))
          (eglot-capf (styles basic))))
  (add-hook 'eglot-managed-mode-hook
          (lambda ()
            (eglot-inlay-hints-mode -1)
            (evil-local-set-key 'normal (kbd "K") #'eldoc)))
  (add-to-list 'eglot-server-programs
               '(rust-mode . ("rust-analyzer"
                              :initializationOptions
                              (:check (:command "clippy")))))
  (add-to-list 'eglot-server-programs
               '(typst-mode . ("tinymist")))
  (add-to-list 'eglot-server-programs
               '(nix-mode . ("nixd"))))

(add-hook 'typst-mode-hook
          (lambda ()
            (setq-local compile-command
                        (concat "typst compile --diagnostic-format short "
                                (shell-quote-argument buffer-file-name)))))

(evil-define-key '(normal visual) 'global (kbd "<leader>ca") 'eglot-code-actions)
(evil-define-key '(normal visual) 'global (kbd "<leader>cr") 'eglot-rename)
(evil-define-key '(normal visual) 'global (kbd "<leader>cd") 'flymake-show-buffer-diagnostics)

(use-package rust-mode)
(use-package nix-mode)
(use-package tuareg)

(use-package vterm)
(evil-define-key 'normal 'global (kbd "SPC o t") 'vterm-other-window)

(use-package magit)

(defun my/split-window-horizontally-and-focus()
  (interactive)
  (select-window (split-window-horizontally)))

(defun my/split-window-vertically-and-focus()
  (interactive)
  (select-window (split-window-vertically)))

(define-key evil-window-map "s" #'my/split-window-vertically-and-focus)
(define-key evil-window-map "v" #'my/split-window-horizontally-and-focus)

(defun my/save-kill-buffer-and-window ()
  (interactive)
  (when (and buffer-file-name (buffer-modified-p))
    (save-buffer))
  (kill-buffer-and-window))

(use-package ef-themes
  :init
  (ef-themes-take-over-modus-themes-mode 1)
  :config
  (setq modus-themes-mixed-fonts nil)
  (setq modus-themes-italic-constructs nil)
  (modus-themes-load-theme 'ef-dark))
