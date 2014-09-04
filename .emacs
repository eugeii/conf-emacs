;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; .emacs
;;;;
;;;; Personal Emacs configuration file, designed to be compatible with both
;;;; normal Emacs, as well as Evil mode.
;;;;
;;;; Author: Eugene Ching <eugene@enegue.com>
;;;; Created: 10 Oct 2013
;;;;
;;;; Copyright (C) 2013 - * Eugene Ching
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; Packages
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Repositories
(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;;; Installer
(mapc
 (lambda (package)
   (or (package-installed-p package)
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package))))
 '(color-theme-monokai monokai-theme
   smart-mode-line expand-region adaptive-wrap paredit e2wm icicles tabbar
   exec-path-from-shell
   evil evil-leader evil-paredit key-chord
   autopair highlight-symbol
   multiple-cursors mc-extras
   powershell-mode python-mode markdown-mode web-mode emmet-mode go-mode lua-mode
   clojure-mode nrepl))


(defun forward-word-to-beginning (&optional n)
  "Move point forward n words and place cursor at the beginning."
  (interactive "p")
  (let (myword)
	(setq myword
		  (if (and transient-mark-mode mark-active)
			  (buffer-substring-no-properties (region-beginning) (region-end))
			(thing-at-point 'symbol)))
	(if (not (eq myword nil))
		(forward-word n))
	(forward-word n)
	(backward-word n)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; Editor configuration
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Theme
(load-theme 'monokai t)

;;; Editor behavior
(transient-mark-mode 1)                  ; highlight text selection
(delete-selection-mode 1)                ; delete seleted text when typing
(global-font-lock-mode 1)                ; turn on syntax coloring
(show-paren-mode 1)                      ; turn on paren match highlighting
(setq show-paren-style 'expression)      ; highlight entire bracket expression
(setq line-move-visual t)                ; Visual movement (rather than line based movement)
(setq-default truncate-lines 1)          ; Default no line wrap

;;; Search
(setq lazy-highlight-cleanup nil)        ; Persistent highlights
(setq lazy-highlight-max-at-a-time nil)
(setq lazy-highlight-initial-delay 0)

;;; Backups and files
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
	  backup-by-copying t                    ; Don't delink hardlinks
	  version-control t                      ; Use version numbers on backups
	  delete-old-versions t                  ; Automatically delete excess backups
	  kept-new-versions 20                   ; how many of the newest versions to keep
	  kept-old-versions 5)                   ; and how many of the old

;;; Suppress GUI elements
(defalias 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-echo-area-message t)
(setq inhibit-startup-message t)
(setf inhibit-splash-screen t)
(setq use-dialog-box nil)
(tool-bar-mode -1)
(menu-bar-mode -1)

;;; Scrolling
(setq redisplay-dont-pause t
	  scroll-margin 1
	  scroll-step 1
	  scroll-conservatively 10000
	  scroll-preserve-screen-position 1)
(setq mouse-wheel-scroll-amount '(4 ((shift) . 4) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse 't)
(setq scroll-step 1)

;;; GUI options
(global-linum-mode 1)                               ; Show line numbers
(column-number-mode 1)                              ; Display column number
(setq frame-title-format '("%b - %f"))              ; Window title
(adaptive-wrap-prefix-mode 1)                       ; Wrap
(switch-to-buffer (get-buffer-create "empty"))      ; Start with blank screen
(delete-other-windows)

;;; Text settings
(setq fill-column 100)
(setq-default tab-width 4)

;;; Visual line mode
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))


;;; Emacs frame size
(defun set-frame-size-according-to-resolution ()
  (interactive)
  (if window-system
  (progn
	(if (eq system-type 'windows-nt)
		;; Set font
		(set-face-attribute 'default nil :font "Consolas"))
	(if (eq system-type 'gnu/linux)
		;; Set font
		(set-face-attribute 'default nil :font "Droid Sans Mono"))
		
		
	;; Set position to origin
	(set-frame-position (selected-frame) 0 0)
	
    ;; use 120 char wide window for largeish displays
    ;; and smaller 80 column windows for smaller displays
    ;; pick whatever numbers make sense for you
    (if (> (x-display-pixel-width) 1280)
		(add-to-list 'default-frame-alist (cons 'width 120))
	  (add-to-list 'default-frame-alist (cons 'width 80)))

    ;; for the height, subtract a couple hundred pixels
    ;; from the screen height (for panels, menubars and
    ;; whatnot), then divide by the height of a char to
    ;; get the height we want
    (add-to-list 'default-frame-alist 
         (cons 'height (/ (- (x-display-pixel-height) 200)
                             (frame-char-height)))))))

(set-frame-size-according-to-resolution)

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))


;;; ----------------------------------------------------------------------------
;;; Custom movement and editing
;;; ----------------------------------------------------------------------------

(defun delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point)
				 (progn
				   (evil-forward-word-begin-shift-support)
				   (point))))

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point)
				 (progn
				   (evil-backward-word-begin-shift-support)
				   (point))))


;;; ----------------------------------------------------------------------------
;;; Windowing behavior 
;;; ----------------------------------------------------------------------------

(defun swap-windows ()
  "If you have 2 windows, it swaps them."
  (interactive)
  (cond ((not (= (count-windows) 2)) (message "You need exactly 2 windows to do this."))
		(t
		 (let* ((w1 (first (window-list)))
				(w2 (second (window-list)))
				(b1 (window-buffer w1))
				(b2 (window-buffer w2))
				(s1 (window-start w1))
				(s2 (window-start w2)))
		   (set-window-buffer w1 b2)
		   (set-window-buffer w2 b1)
		   (set-window-start w1 s2)
		   (set-window-start w2 s1)))))

(defun toggle-split-direction ()
  "If the frame is split vertically, split it horizontally or vice versa.
Assumes that the frame is only split into two."
  (interactive)
  (unless (= (length (window-list)) 2)
	(error "Can only toggle a frame split in two"))
  (let ((split-vertically-p (window-combined-p)))
    (delete-window) ; closes current window
    (if split-vertically-p
        (split-window-horizontally)
      (split-window-vertically)) ; gives us a split with the other window twice
    (switch-to-buffer nil))) ; restore the original window in this part of the frame

;;; I don't use the default binding of 'C-x 5', so use toggle-frame-split instead
(global-set-key (kbd "C-x 5") 'toggle-frame-split)

(defun switch-to-previous-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))


;;; ----------------------------------------------------------------------------
;;; File handling
;;; ----------------------------------------------------------------------------

(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
		(filename (buffer-file-name)))
	(if (not filename)
		(message "Buffer '%s' is not visiting a file!" name)
	  (if (get-buffer new-name)
		  (message "A buffer named '%s' already exists!" new-name)
		(progn
		  (rename-file name new-name 1)
		  (rename-buffer new-name)
		  (set-visited-file-name new-name)
		  (set-buffer-modified-p nil))))))

(defun move-buffer-file (dir)
  "Moves both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
  (let* ((name (buffer-name))
		 (filename (buffer-file-name))
		 (dir
		  (if (string-match dir "\\(?:/\\|\\\\)$")
			  (substring dir 0 -1) dir))
		 (newname (concat dir "/" name)))
	(if (not filename)
		(message "Buffer '%s' is not visiting a file!" name)
	  (progn
		(copy-file filename newname 1)
		(delete-file filename)
		(set-visited-file-name newname)
		(set-buffer-modified-p nil)
		t)))) 

(defun open-buffer-path ()
  "Run explorer on the directory of the current buffer."
  (interactive)
  (shell-command
   (concat "explorer "
		   (replace-regexp-in-string "/" "\\" (file-name-directory (buffer-file-name)) t t))))


;;; ----------------------------------------------------------------------------
;;; Mark and selection
;;; ----------------------------------------------------------------------------

(defun push-mark-no-activate ()
  "Pushes `point' to `mark-ring' and does not activate the region.
Equivalent to \\[set-mark-command] when \\[transient-mark-mode] is disabled."
  (interactive)
  (push-mark (point) t nil)
  (message "Pushed mark to ring"))

(defun jump-to-mark ()
  "Jumps to the local mark, respecting the `mark-ring' order.
This is the same as using \\[set-mark-command] with the prefix argument."
  (interactive)
  (set-mark-command 1))

(defun mark-whole-buffer-nomove ()
  "Select the entire buffer without moving the cursor."
  (interactive)
  (save-excursion
    (mark-whole-buffer)))

(defun copy-whole-buffer-nomove ()
  "Copy the entire buffer without moving the cursor."
  (interactive)
  (clipboard-kill-ring-save (point-min) (point-max))
  (message "Copied entire buffer."))


;;; ----------------------------------------------------------------------------
;;; Evaluation
;;; ----------------------------------------------------------------------------

(defun eval-expression-at-point ()
  (if (fboundp 'nrepl-eval-expression-at-point)
	  (nrepl-eval-expression-at-point)
	(eval-last-sexp)))


;;; ----------------------------------------------------------------------------
;;; Exit
;;; ----------------------------------------------------------------------------

(defun save-buffers-and-close-emacs (&optional arg)
  "Offer to save each buffer (once only), then kill this Emacs process.
With prefix ARG, silently save all file-visiting buffers, then kill."
  (interactive "P")
  (save-some-buffers arg t)
  (and (or (not (fboundp 'process-list))
		   ;; process-list is not defined on MSDOS.
		   (let ((processes (process-list))
				 active)
			 (while processes
			   (and (memq (process-status (car processes)) '(run stop open listen))
					(process-query-on-exit-flag (car processes))
					(setq active t))
			   (setq processes (cdr processes)))
			 (or (not active)
				 (progn (list-processes t)
						(yes-or-no-p "Active processes exist; kill them and exit anyway? ")))))
       ;; Query the user for other things, perhaps.
       (run-hook-with-args-until-failure 'kill-emacs-query-functions)
       (or (null confirm-kill-emacs)
		   (funcall confirm-kill-emacs "Really exit Emacs? "))
       (kill-emacs)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; Various modes
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Function that loads all the requires and modes only when we want
;;; them. This prevents a slow-loading Emacs on start.

(defun start-full-emacs ()
  (interactive)
  (require 'e2wm)
  (require 'icicles)
  (icy-mode 1)
  (require 'tabbar)
  (tabbar-mode))

;;; ----------------------------------------------------------------------------
;;; C/C++ mode
;;; ----------------------------------------------------------------------------

(setq c-block-comment-prefix "*")
(setq c-comment-prefix-regexp "//+\\ | \\**")

(add-hook 'c-mode-hook
		  (lambda ()
			(setq indent-tabs-mode t)
			(setq tab-width 4)
			(setq python-indent 4)
			(setq comment-style 'multi-line)))

(add-hook 'c++-mode-hook
		  (lambda ()
			(setq indent-tabs-mode t)
			(setq tab-width 4)
			(setq python-indent 4)
			(setq comment-style 'multi-line)))


;;; ----------------------------------------------------------------------------
;;; Python mode
;;; ----------------------------------------------------------------------------

(add-hook 'python-mode-hook
		  (lambda ()
			(setq indent-tabs-mode t)
			(setq tab-width 4)
			(setq python-indent 4)))


;;; ----------------------------------------------------------------------------
;;; Go mode
;;; ----------------------------------------------------------------------------

(add-hook 'go-mode-hook
		  (lambda ()
			(global-set-key [(f9)] 'gofmt)))

(add-hook 'before-save-hook 'gofmt-before-save)


;;; ----------------------------------------------------------------------------
;;; e2wm mode
;;; ----------------------------------------------------------------------------

(global-set-key (kbd "M-+") 'e2wm:start-management)
(global-set-key (kbd "M-=") 'e2wm:stop-management)


;;; ----------------------------------------------------------------------------
;;; Tab bar mode
;;; ----------------------------------------------------------------------------

; Look and feel of tab bar
(setq tabbar-background-color "#E04E39") ;; the color of the tabbar background
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#1B1E1C" "#FF1493" "#87D700" "#CDC673" "#5FD7FF" "#D700D7" "#5FFFFF" "#F5F5F5"])
 '(compilation-message-face (quote default))
 '(custom-safe-themes (quote ("60f04e478dedc16397353fb9f33f0d895ea3dab4f581307fbf0aa2f07e658a40" default)))
 '(fci-rule-color "#303030")
 '(highlight-changes-colors (quote ("#D700D7" "#AF87FF")))
 '(highlight-tail-colors (quote (("#303030" . 0) ("#B3EE3A" . 20) ("#AFEEEE" . 30) ("#8DE6F7" . 50) ("#FFF68F" . 60) ("#FFA54F" . 70) ("#FE87F4" . 85) ("#303030" . 100))))
 '(magit-diff-use-overlays nil)
 '(syslog-debug-face (quote ((t :background unspecified :foreground "#5FFFFF" :weight bold))))
 '(syslog-error-face (quote ((t :background unspecified :foreground "#FF1493" :weight bold))))
 '(syslog-hour-face (quote ((t :background unspecified :foreground "#87D700"))))
 '(syslog-info-face (quote ((t :background unspecified :foreground "#5FD7FF" :weight bold))))
 '(syslog-ip-face (quote ((t :background unspecified :foreground "#CDC673"))))
 '(syslog-su-face (quote ((t :background unspecified :foreground "#D700D7"))))
 '(syslog-warn-face (quote ((t :background unspecified :foreground "#FF8C00" :weight bold))))
 '(tabbar-separator (quote (1.0)))
 '(vc-annotate-background nil)
 '(vc-annotate-color-map (quote ((20 . "#FF1493") (40 . "#CF4F1F") (60 . "#C26C0F") (80 . "#CDC673") (100 . "#AB8C00") (120 . "#A18F00") (140 . "#989200") (160 . "#8E9500") (180 . "#87D700") (200 . "#729A1E") (220 . "#609C3C") (240 . "#4E9D5B") (260 . "#3C9F79") (280 . "#5FFFFF") (300 . "#299BA6") (320 . "#2896B5") (340 . "#2790C3") (360 . "#5FD7FF"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list (quote (unspecified "#1B1E1C" "#303030" "#5F0000" "#FF1493" "#6B8E23" "#87D700" "#968B26" "#CDC673" "#21889B" "#5FD7FF" "#A41F99" "#D700D7" "#349B8D" "#5FFFFF" "#F5F5F5" "#FFFAFA"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(tabbar-button ((t (:inherit tabbar-default :foreground "dark red"))))
 '(tabbar-button-highlight ((t (:inherit tabbar-default))))
 '(tabbar-default ((t (:inherit variable-pitch :background "#E04E39" :foreground "black" :weight bold))))
 '(tabbar-highlight ((t (:underline t))))
 '(tabbar-selected ((t (:inherit tabbar-default :background "#B04E39"))))
 '(tabbar-separator ((t (:inherit tabbar-default :background "#E04E39"))))
 '(tabbar-unselected ((t (:inherit tabbar-default)))))

; Hide special buffers so they don't clutter up the tab bar
(when (require 'tabbar nil t)
  (setq tabbar-buffer-groups-function
		(lambda (b) (list "All Buffers")))
  (setq tabbar-buffer-list-function
		(lambda ()
		  (remove-if
		   (lambda(buffer)
			 (find (aref (buffer-name buffer) 0) " *"))
		   (buffer-list))))
  ;; (tabbar-mode)
  )

(setq tabbar-buffer-groups-function
	  (lambda ()
		(list "All")))

; Move between tabs
(global-set-key [M-left] 'tabbar-backward-tab)
(global-set-key [M-right] 'tabbar-forward-tab)


;;; ----------------------------------------------------------------------------
;;; Icicles mode
;;; ----------------------------------------------------------------------------

;; (require 'icicles)


;;; ----------------------------------------------------------------------------
;;; Org mode
;;; ----------------------------------------------------------------------------

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(setq org-startup-indented t)
(setq org-export-html-postamble nil)

(defun get-string-from-file (file-path)
  "Return file-path's file content."
  (with-temp-buffer
    (insert-file-contents file-path)
    (buffer-string)))

(defun get-org-mode-css-stylesheet (css-file-name)
  ;; Get custom CSS style sheet for org-mode, if available
  (ignore-errors
	(let ((css (format "<style>%s</style>" (get-string-from-file css-file-name))))
	  (setq org-export-html-style css))))

(get-org-mode-css-stylesheet "~/org-mode-style.css")


;;; ----------------------------------------------------------------------------
;;; Paredit mode
;;; ----------------------------------------------------------------------------

(add-hook 'emacs-lisp-mode-hook 'paredit-mode)


;;; ----------------------------------------------------------------------------
;;; Powershell mode
;;; ----------------------------------------------------------------------------

(autoload 'powershell-mode "powershell-mode" "A editing mode for Microsoft PowerShell." t)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode)) ; PowerShell script
(setq powershell-indent 2)


;;; ----------------------------------------------------------------------------
;;; Highlight symbol mode
;;; ----------------------------------------------------------------------------

(setq highlight-symbol-idle-delay 0)


;;; ----------------------------------------------------------------------------
;;; Smart mode line
;;; ----------------------------------------------------------------------------

(require 'smart-mode-line)


;;; ----------------------------------------------------------------------------
;;; Evil mode
;;; ----------------------------------------------------------------------------

;;; Evil support

(defmacro without-evil-mode (&rest do-this)
  "Check if evil-mode is on, and disable it temporarily"
  `(let ((evil-mode-is-on (evil-mode?)))
     (if evil-mode-is-on
		 (disable-evil-mode))
     (ignore-errors
	   ,@do-this)
	 (if evil-mode-is-on
		 (enable-evil-mode))))

(defmacro evil-mode? ()
  "Checks if evil mode is active. Uses Evil's state to check."
  `evil-state)

(defmacro disable-evil-mode ()
  "Disable evil mode with visual cues."
  `(progn
     (evil-mode 0)
     (message "Evil mode disabled")
     (setq cursor-type 'bar)))
     ;; (custom-set-variables
	 ;;  '(sml/active-background-color "steelblue4"))))

(defmacro enable-evil-mode ()
  "Enable evil mode with visual cues."
  `(progn
     (evil-mode 1)
     (message "Evil mode enabled")
     (setq cursor-type 'block)))
     ;; (custom-set-variables
	 ;;  '(sml/active-background-color "gray20"))

(defun toggle-evil-mode ()
  "Toggles evil mode with visual cues."
  (interactive)
  (if (evil-mode?)
	  (disable-evil-mode)
	(enable-evil-mode)))


;;; Initialize Evil

(enable-evil-mode)


;;; Evil behavior

(defun evil-search-nomove (string forward &optional regexp-p start)
  "Supporting function for evil-superstar."
  (ignore-errors
	(backward-char 1))
  (when (and (stringp string)
             (not (string= string "")))
    ;; Move to the beginning of the word
    (let* ((orig (point))
           (start (or start
                      (if forward
                          (min (point-max) orig)
                        orig)))
           (isearch-regexp regexp-p)
           (isearch-forward forward)
           (case-fold-search
            (unless (and search-upper-case
                         (not (isearch-no-upper-case-p string nil)))
              case-fold-search))
           (search-func (evil-search-function
                         forward regexp-p evil-search-wrap)))
      (set-text-properties 0 (length string) nil string)
      (goto-char start)
      (condition-case nil
          (funcall search-func string)
        (search-failed
         (goto-char orig)
         (error "\"%s\": %s not found"
                string (if regexp-p "pattern" "string"))))
      (setq isearch-string string)
      (isearch-update-ring string regexp-p)
      (cond
       ((boundp 'isearch-filter-predicates)
        (dolist (pred isearch-filter-predicates)
          (funcall pred (match-beginning 0) (match-end 0))))
       ((boundp 'isearch-filter-predicate)
        (funcall isearch-filter-predicate (match-beginning 0) (match-end 0))))
      (cond
       ((and forward (< (point) start))
        (setq string "Search wrapped around BOTTOM of buffer"))
       ((and (not forward) (> (point) start))
        (setq string "Search wrapped around TOP of buffer"))
       (t
        (setq string (evil-search-message string forward))))
      (evil-flash-search-pattern string t))))

(defun evil-search-symbol-nomove (forward &optional unbounded)
  "Supporting function for evil-superstar."
  (if (looking-at "\\<") () (re-search-backward "\\<" (point-min)))
  (let ((string (car-safe regexp-search-ring))
        (move (if forward #'forward-char #'backward-char))
        (end (if forward #'eobp #'bobp)))
    (setq isearch-forward forward)
    (cond
     ((and (memq last-command
                 '(evil-search-symbol-forward
                   evil-search-symbol-backward))
           (stringp string)
           (not (string= string "")))
      (evil-search string forward t))
     (t
      (setq string (evil-find-symbol forward))
      (cond
       ((null string)
        (error "No symbol under point"))
       (unbounded
        (setq string (regexp-quote string)))
       (t
        (setq string (format "\\_<%s\\_>" (regexp-quote string)))))
	  (message string)
      (evil-search-nomove string forward t)))))

(evil-define-motion evil-superstar ()
  "Implement's Vim's superstar-like functionality. Hitting * will
search for the word under the current cursor, without moving the
cursor."
  (interactive)
  (save-excursion
    (save-window-excursion
      (evil-search-symbol-nomove 1))))

(defun evil-clean-isearch-overlays ()
  "Forcibly enable persistent highlight of search results, like
Vim's hlsearch."
  (remove-hook 'pre-command-hook #'evil-clean-isearch-overlays t)
  (unless (memq this-command
                '(evil-search-backward
                  evil-search-forward
                  evil-search-next
                  evil-search-previous
                  evil-search-symbol-backward
                  evil-search-symbol-forward))))

(defun evil-flash-hook (&optional force)
  "Forcibly enable persistent highlight of search results, like
Vim's hlsearch."
  (when (or force
            ;; To avoid flicker, don't disable highlighting
            ;; if the next command is also a search command
            (not (memq this-command
                       '(evil-search-backward
                         evil-search-forward
                         evil-search-next
                         evil-search-previous
                         evil-search-symbol-backward
                         evil-search-symbol-forward))))
    (evil-echo-area-restore)
    (setq isearch-lazy-highlight-last-string nil)
    (lazy-highlight-cleanup nil)
    (when evil-flash-timer
      (cancel-timer evil-flash-timer)))
  (remove-hook 'pre-command-hook #'evil-flash-hook t)
  (remove-hook 'evil-operator-state-exit-hook #'evil-flash-hook t))

(defun evil-clear-highlights ()
  "Remove all the search highlights."
  (interactive)
  (lazy-highlight-cleanup t)
  (isearch-clean-overlays)
  (isearch-dehighlight))

(defun evil-copy-to-end-of-line ()
  "Copies text in a line from cursor to the end."
  (interactive)
  (evil-yank (point) (point-at-eol)))

(defun evil-open-above-ret-normal-mode ()
  "Creates a new line at cursor while staying in normal mode."
  (interactive)
  (evil-open-above 1)
  (evil-normal-state))

(defun comment-or-uncomment-region-or-line ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
										; Grab beginning and end of active region, if any
    (if (region-active-p)
		(setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))

										; If line is blank, create a new comment. Else, comment out the line.
    (if     (and (/= (line-beginning-position) (line-end-position))
				 (not (string-match "^\s+$" (buffer-substring beg end))))
		(comment-or-uncomment-region beg end)
      (progn
		(comment-dwim nil)))))


;;; Clipboard bypass

;; delete: char
(evil-define-operator evil-destroy-char (beg end type register yank-handler)
  "Vim's 'x' without clipboard"
  :motion evil-forward-char
  (evil-delete-char beg end type ?_))

;; delete: char (backwards)
(evil-define-operator evil-destroy-backward-char (beg end type register yank-handler)
  "Vim's 'backspace' without clipboard."
  :motion evil-forward-char
  (evil-delete-backward-char beg end type ?_))

;; delete: text object
(evil-define-operator evil-destroy (beg end type register yank-handler)
  "Vim's 's' without clipboard."
  (evil-delete beg end type ?_ yank-handler))

;; delete: to end of line
(evil-define-operator evil-destroy-line (beg end type register yank-handler)
  "Vim's 'S' without clipboard."
  :motion nil
  :keep-visual t
  (interactive "<R><x>")
  (evil-delete-line beg end type ?_ yank-handler))

;; delete: whole line
(evil-define-operator evil-destroy-whole-line (beg end type register yank-handler)
  "Vim's 'X' without clipboard."
  :motion evil-line
  (interactive "<R><x>")
  (evil-delete-whole-line beg end type ?_ yank-handler))

;; change: text object
(evil-define-operator evil-destroy-change (beg end type register yank-handler delete-func)
  "Vim's 'c' without clipboard."
  (evil-change beg end type ?_ yank-handler delete-func))

;; paste: before
(defun evil-destroy-paste-before ()
  "Vim's 'P' without clipboard."
  (interactive)
  (without-evil-mode
   (delete-region (point) (mark))
   (evil-paste-before 1)))

;; paste: after
(defun evil-destroy-paste-after ()
  "Vim's 'p' without clipboard."
  (interactive)
  (without-evil-mode
   (delete-region (point) (mark))
   (evil-paste-after 1)))

;; paste: text object
(evil-define-operator evil-destroy-replace (beg end type register yank-handler)
  "Paste with text objects."
  (evil-destroy beg end type register yank-handler)
  (evil-paste-before 1 register))


;;; Evil movement

(evil-define-motion evil-little-word (count)
  "Defines a little word motion as oneTwoThree. Hence, one, two and three are all considered words."
  :type exclusive
  (let* ((case-fold-search nil)
         (count (if count count 1)))
    (while (> count 0)
      (forward-char)
      (search-forward-regexp "[_A-Z]\\|\\W" nil t)
      (backward-char)
      (decf count))))

(defun evil-toggle-line-wrap (&optional arg)
  "Toggle line wrapping on and off."
  (interactive "P")
  (if truncate-lines
      ;; No word wrap, turn it on
      (progn
		(visual-line-mode 1)
		(toggle-truncate-lines 0)
		(define-key evil-normal-state-map "j" 'evil-next-visual-line)
		(define-key evil-normal-state-map "k" 'evil-previous-visual-line)
		(define-key evil-visual-state-map "j" 'evil-next-visual-line)
		(define-key evil-visual-state-map "k" 'evil-previous-visual-line)
		(define-key evil-normal-state-map [down] 'evil-next-visual-line)
		(define-key evil-normal-state-map [up] 'evil-previous-visual-line)
		(define-key evil-visual-state-map [down] 'evil-next-visual-line)
		(define-key evil-visual-state-map [up] 'evil-previous-visual-line))
    ;; Word wrapped, turn it off
    (progn
      (visual-line-mode 0)
      (toggle-truncate-lines 1)
      (define-key evil-normal-state-map "j" 'evil-next-line)
      (define-key evil-normal-state-map "k" 'evil-previous-line)
      (define-key evil-visual-state-map "j" 'evil-next-line)
      (define-key evil-visual-state-map "k" 'evil-previous-line)
      (define-key evil-normal-state-map [down] 'evil-next-line)
      (define-key evil-normal-state-map [up] 'evil-previous-line)
      (define-key evil-visual-state-map [down] 'evil-next-line)
      (define-key evil-visual-state-map [up] 'evil-previous-line)))
  (message "Line wrapping %s" (if truncate-lines "disabled" "enabled")))

(defun evil-forward-word-begin-shift-support ()
  "Move to previous word."
  (interactive "^")
  (evil-forward-word-begin))

(defun evil-backward-word-begin-shift-support ()
  "Move to next word."
  (interactive "^")
  (evil-backward-word-begin))


;;; Evil visual selection

(defun evil-select-current-line ()
  "Select visually the current line, without the newline."
  (interactive "^")
  (evil-beginning-of-visual-line)
  (set-mark-command nil)
  (evil-end-of-visual-line))


;;; Evil sexp

(defmacro left-parenthesis? ()
  "Tests if the current character is a '(' character."
  `(= (char-after) 40))

(defmacro right-parenthesis? ()
  "Tests if the current character is a ')' character."
  `(= (char-after) 41))

(defmacro previous-left-parenthesis ()
  "Noves to the first previous '(' character."
  `(progn
     (backward-up-sexp 1)
     (while (not (left-parenthesis?))  ; Detect '('
	   (backward-up-sexp 1))))

(defun backward-up-sexp (arg)
  "Moves to the previous enclosing sexp."
  (interactive "p")
  (let ((ppss (syntax-ppss)))
    (cond ((elt ppss 3)
           (goto-char (elt ppss 8))
           (backward-up-sexp (1- arg)))
          ((backward-up-list arg)))))

(defun evil-backward-sexp ()
  "Move to start of current sexp."
  (interactive "^")
  (previous-left-parenthesis))

(defun evil-forward-sexp ()
  "Jump to end of current sexp."
  (interactive "^")
  (unless (left-parenthesis?)    ; If on '(', directly jump
	(if (right-parenthesis?)     ; Escape current ')'
		(forward-char 1))
	(previous-left-parenthesis)) ; Find the previous left parenthesis
  (evil-jump-item))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; Key bindings
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; ----------------------------------------------------------------------------
;;; Key bindings for Emacs
;;; ----------------------------------------------------------------------------

;;; Delete behavior
(global-set-key (kbd "<C-backspace>") 'backward-delete-word)
(global-set-key (kbd "<C-delete>") 'delete-word)
(global-set-key (kbd "<delete>") 'evil-destroy-char)

;;; Search behavior
(global-set-key (kbd "<C-s>") 'evil-search-forward)

;;; Newline calls indent
(global-set-key (kbd "RET") 'newline-and-indent)

;;; Undo
(global-set-key (kbd "C-z") 'undo)

;;; Expand-region
(global-set-key "\M- " 'er/expand-region)

;;; Mark
(global-set-key (kbd "C-`") 'push-mark-no-activate)
(global-set-key (kbd "M-`") 'jump-to-mark)

;;; Change window
(global-set-key (kbd "<C-tab>") 'other-window)
(global-set-key (kbd "C-,") 'other-window)

;;; Save and close
(fset 'save-buffers-kill-emacs 'save-buffers-and-close-emacs)

;;; Copy/select entire buffer
(global-set-key (kbd "C-c C-a") 'copy-whole-buffer-nomove)
;; (global-set-key (kbd "C-a") 'mark-whole-buffer)

;;; Toggle highlight symbol (under cursor)
(global-set-key [(f6)] 'highlight-symbol-mode)

;;; Toggle split direction
(global-set-key [(f11)] 'toggle-split-direction)

;;; Switch to previous most recently used buffer
(global-set-key [(f4)] 'switch-to-previous-buffer)

;;; ----------------------------------------------------------------------------
;;; Key bindings for Modes
;;; ----------------------------------------------------------------------------

;;; Helm mode ------------------------------------

(global-set-key [(f12)] 'start-full-emacs)


;;; Multicursors mode ----------------------------

(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-M->") 'mc/skip-to-next-like-this)
(global-set-key (kbd "C-M-<") 'mc/skip-to-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key [M-f3] 'mc/mark-all-symbols-like-this)


;;; Evil mode (leader) ---------------------------

;;; Leader key and mappings
(global-evil-leader-mode)
(evil-leader/set-leader ",")
(evil-leader/set-key
  "v" (lambda () (interactive) (find-file "~/.emacs"))
  "|" (lambda () (interactive) (split-window-right))           ; Window vertical split
  "-" (lambda () (interactive) (split-window-below))           ; Window horizontal split
  "q" (lambda () (interactive) (delete-window))                ; Delete window
  "1" (lambda () (interactive) (delete-other-windows))         ; Delete other windows
  "w" (lambda () (interactive) (select-window (next-window)))  ; Move to next window
  "e" (lambda () (interactive) (open-buffer-path))
  "q" (lambda () (interactive) (eval-expression-at-point))
  "x" (lambda () (interactive) (kill-buffer))
  "b" (lambda () (interactive) (buffer-menu))
  "n" (lambda () (interactive) (switch-to-buffer (get-buffer-create "empty")))
  "f" (lambda () (interactive) (make-frame-command)))
  ;; "f" (lambda () (interactive) (evil-forward-sexp))
  ;; "b" (lambda () (interactive) (evil-backward-sexp))


; Escape key behavior
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)


;;; Evil mode ------------------------------------

;; Map <space> to ":"
(define-key evil-motion-state-map " " 'evil-ex)

;; Movement
(global-set-key [C-right] 'evil-forward-word-begin-shift-support)
(global-set-key [C-left] 'evil-backward-word-begin-shift-support)

;; Undo / redo
(define-key evil-normal-state-map (kbd "C-z") 'undo)
(define-key evil-insert-state-map (kbd "C-z") 'undo)
(define-key evil-normal-state-map (kbd "C-r") 'undo-tree-redo)
(define-key evil-insert-state-map (kbd "C-r") 'undo-tree-redo)

;; Commenting
(define-key evil-normal-state-map (kbd "C-\\") 'comment-or-uncomment-region-or-line)
(define-key evil-insert-state-map (kbd "C-\\") 'comment-or-uncomment-region-or-line)

;; Tabs and indents
(define-key evil-normal-state-map (kbd "<tab>") 'indent-for-tab-command)

;; Miscelleanous
(define-key evil-normal-state-map "-" 'evil-end-of-line)
(define-key evil-normal-state-map (kbd "M-o") 'evil-open-above-ret-normal-mode)
(define-key evil-normal-state-map [(f8)] 'delete-trailing-whitespace)
(define-key evil-normal-state-map [(f5)] 'revert-buffer)

;; Cut, copy, paste behavior
(define-key evil-normal-state-map "s" 'evil-destroy)
(define-key evil-normal-state-map "S" 'evil-destroy-line)
(define-key evil-normal-state-map "c" 'evil-destroy-change)
(define-key evil-normal-state-map "x" 'evil-destroy-char)
(define-key evil-normal-state-map "X" 'evil-destroy-whole-line)
(define-key evil-normal-state-map "Y" 'evil-copy-to-end-of-line)
(define-key evil-visual-state-map "P" 'evil-destroy-paste-before)
(define-key evil-visual-state-map "p" 'evil-destroy-paste-after)

;; Prevent bindings
(defun evil-undefine ()
  (interactive)
  (let (evil-mode-map-alist)
	(call-interactively (key-binding (this-command-keys)))))

;; Escape behaviour
(defun evil-escape-everything ()
  "Escape everything, clear the mark."
  (interactive "^")
  (evil-exit-visual-state)
  (evil-normal-state))

(setq key-chord-two-keys-delay 0.1)
;; (key-chord-define evil-visual-state-map "jk" 'evil-exit-visual-state)
;; (key-chord-define evil-visual-state-map "kj" 'evil-exit-visual-state)
;; (key-chord-define evil-insert-state-map "jk" 'evil-escape-everything)
;; (key-chord-define evil-insert-state-map "kj" 'evil-escape-everything)
(key-chord-mode 1)

;; Selection behavior
(key-chord-define evil-normal-state-map "vv" 'evil-select-current-line)

;; Delimiters
(define-key evil-operator-state-map (kbd "lw") 'evil-little-word)

;; Searching
(define-key evil-normal-state-map "*" 'evil-superstar)
(define-key evil-normal-state-map "#" 'evil-clear-highlights)

;; Toggle line wrapping
(global-set-key [(f2)] 'evil-toggle-line-wrap)

;; Toggle evil mode
(global-set-key [(f3)] 'toggle-evil-mode)

;; Move by s-expression (sexp)
;; (define-key evil-normal-state-map (kbd "M-(") 'evil-backward-sexp)
;; (define-key evil-normal-state-map (kbd "M-)") 'evil-forward-sexp)


;;; Start Emacs server

; Suppress error "directory ~/.emacs.d/server is unsafe" on Windows.
;; (require 'server)
;; (when (and (>= emacs-major-version 23)
;;            (equal window-system 'w32))
;;   (defun server-ensure-safe-dir (dir) "Noop" t)) 
;; (server-start)


;;; Re-initialize Evil

(enable-evil-mode)

;;; Re-initialize Evil


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; Evil mode overrides
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Home/end behavior
(define-key evil-normal-state-map (kbd "<C-a>") 'evil-undefine)
(define-key evil-normal-state-map (kbd "<C-e>") 'evil-undefine)
(define-key evil-normal-state-map (kbd "<C-d>") 'evil-undefine)

(define-key evil-normal-state-map "\C-a" 'evil-beginning-of-line)
(define-key evil-motion-state-map "\C-a" 'evil-beginning-of-line)
(define-key evil-insert-state-map "\C-a" 'beginning-of-line)

(define-key evil-normal-state-map "\C-e" 'evil-end-of-line)
(define-key evil-motion-state-map "\C-e" 'evil-end-of-line)
(define-key evil-insert-state-map "\C-e" 'end-of-line)

(define-key evil-normal-state-map "\C-d" 'evil-delete-char)
(define-key evil-motion-state-map "\C-d" 'evil-delete-char)
(define-key evil-insert-state-map "\C-d" 'evil-delete-char)

(start-full-emacs)
(setq ns-pop-up-frames nil)
