;; -*-lisp-*-
(in-package :stumpwm)
(setf *default-package* :stumpwm)

(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

(init-load-path #p"~/.stumpwm.d/modules/")
;; Load Slynk package
(ql:quickload :slynk)

;; Contrib module loading
(load-module "stumptray")

;; Custom commands
(defcommand start-slynk () ()
  "Create the slynk server."
  (sb-thread:make-thread
   (lambda ()
     (slynk:create-server :dont-close t))))

(defcommand stop-slynk () ()
  "Stop the slynk server."
  (sb-thread:make-thread
   (lambda ()
     (slynk:stop-server 4005))))

(defcommand run-discord () ()
  "Launch the Discord flatpak."
  (run-shell-command "flatpak run com.discordapp.Discord"))

;; Begin init
(when *initializing*
  (grename "Emacs")
  (gnewbg "Term")
  (gnewbg "Web")
  (gnewbg "Misc")
  (start-slynk))

(clear-window-placement-rules)

(define-frame-preference "Emacs" (nil t t :class "Tiling"))
(define-frame-preference "Term" (nil t t :class "Tiling"))
(define-frame-preference "Web" (nil t t :class "Tiling"))
(define-frame-preference "Misc" (nil t t :class "Tiling"))

;; Theme
(setf *colors*
      '("#3f3f3f"                       ; black
        "#cc9393"                       ; red
        "#7f9f7f"                       ; green
        "#d0bf8f"                       ; yellow
        "#6ca0a3"                       ; blue
        "#dc8cc3"                       ; magenta
        "#93e0e3"                       ; cyan
        "#dcdccc"))                     ; white

(update-color-map (current-screen))

;; Default prefix - Works well on Canary layout with home-row mods
(set-prefix-key (kbd "C-t"))
;;; TOP-MAP keybindings - No prefix
;; Focus
(define-key *top-map* (kbd "s-h") "move-focus left")
(define-key *top-map* (kbd "s-j") "move-focus down")
(define-key *top-map* (kbd "s-k") "move-focus up")
(define-key *top-map* (kbd "s-l") "move-focus right")
(define-key *top-map* (kbd "s-n") "fnext") ; Focus next frame
(define-key *top-map* (kbd "s-p") "fprev") ; Focus previous frame
(define-key *top-map* (kbd "s-N") "next-in-frame") ; Focus the next window in the frame
(define-key *top-map* (kbd "s-P") "prev-in-frame") ; Focus the previous window in the frame
;; Switch to group
(define-key *top-map* (kbd "s-1") "gselect 1")
(define-key *top-map* (kbd "s-2") "gselect 2")
(define-key *top-map* (kbd "s-3") "gselect 3")
(define-key *top-map* (kbd "s-4") "gselect 4")
(define-key *top-map* (kbd "s-5") "gselect 5")
(define-key *top-map* (kbd "s-6") "gselect 6")
(define-key *top-map* (kbd "s-7") "gselect 7")
(define-key *top-map* (kbd "s-8") "gselect 8")
(define-key *top-map* (kbd "s-9") "gselect 9")
(define-key *top-map* (kbd "s-0") "gselect 10")
;; Move window to group
(define-key *top-map* (kbd "s-!") "gmove 1")
(define-key *top-map* (kbd "s-@") "gmove 2")
(define-key *top-map* (kbd "s-#") "gmove 3")
(define-key *top-map* (kbd "s-$") "gmove 4")
(define-key *top-map* (kbd "s-%") "gmove 5")
(define-key *top-map* (kbd "s-^") "gmove 6")
(define-key *top-map* (kbd "s-&") "gmove 7")
(define-key *top-map* (kbd "s-*") "gmove 8")
(define-key *top-map* (kbd "s-(") "gmove 9")
(define-key *top-map* (kbd "s-)") "gmove 10")
;; Conveniences
(define-key *top-map* (kbd "s-RET") "exec alacritty")
(define-key *top-map* (kbd "s-Q") "delete-window")
(define-key *top-map* (kbd "s-K") "kill-window")
(define-key *top-map* (kbd "s-G") "gkill") ; Kill the current group
(define-key *top-map* (kbd "s-E") "quit-confirm")
(define-key *top-map* (kbd "s-d") "exec")
(define-key *top-map* (kbd "s-R") "reload")
(define-key *top-map* (kbd "s-C") "loadrc")
(define-key *top-map* (kbd "s-b") "hsplit")
(define-key *top-map* (kbd "s-v") "vsplit")
(define-key *top-map* (kbd "s-x") "remove-split")

;; Vars
(setf *input-window-gravity* :center
      *message-window-gravity* :center
      *mouse-focus-policy* :sloppy
      *window-format* "%m%n%s%c"
      *screen-mode-line-format* (list "%d " "[%g]" "%W")
      *time-modeline-string* "%a %b %e %Y %R"
      *mode-line-timeout* 2)

;; Personalize the startup message
(setf *startup-message*
      "^2*Welcome to The ^BStump^b ^BW^bindow ^BM^banager ^3*^BBrian^b!
Press ^5*~a ?^2* for help.")

;; Modeline
(enable-mode-line (current-screen) (current-head) t)
;; TODO: Figure out why this tends to cover the date string
(stumptray::stumptray)

;; Autostart some things
(run-shell-command "feh --bg-fill /run/current-system/profile/share/backgrounds/guix/guix-checkered-16-9.svg")
(run-shell-command "xrdb -merge ~/.Xdefaults")
(run-shell-command "emacs")
