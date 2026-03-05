(define-module (guix-home-config)
  #:use-module (guix gexp)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services sway)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services ssh)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu services)
  #:use-module (gnu system shadow)
  #:use-module (gnu packages)
  #:use-module (gnu packages gnupg))

(define home-config
  (home-environment
   (packages
    (specifications->packages
     (list
      "clang-toolchain"        ; provides `cc` unlike `clang` or `gcc-toolchain`
      "cmake"
      "make"
      "gcc-toolchain"
      "libtool"
      "glslang"
      "ripgrep"
      "sbcl"
      "go"
      "gopls"
      "go-github-com-fatih-gomodifytags"
      "gore"
      "rust"
      "python"
      "python-pip"
      "python-black"
      "python-pytest"
      "python-pyflakes"
      "python-isort"
      "ncurses"
      "node"
      "perl"
      "shfmt"
      "htop"
      "tree"
      "neofetch"
      "grimshot"
      "curl"
      "wget"
      "gnupg"
      "pinentry"
      "emacs-pinentry"
      "bitwarden-desktop"
      "flatpak"
      "imagemagick"
      "feh"
      "xdg-utils"
      "xdg-desktop-portal"
      "xdg-desktop-portal-wlr"
      "libportal"
      "pipewire"
      "wireplumber"
      "font-nerd-symbols"
      "emacs-show-font"
      "alacritty"
      "xrdb"
      "rxvt-unicode"
      "scrot"
      "sbcl-stumpwm-ttf-fonts"
      "sbcl-stumpwm-stumptray"
      "sbcl-stumpwm-screenshot"
      "stumpish"
      "stumpwm")))
   (services
    (append
     (list
      (service home-bash-service-type
               (home-bash-configuration
                (environment-variables
                 '(("EDITOR" . "emacs")
                   ("BROWSER" . "qutebrowser")
                   ("XDG_CONFIG_HOME" . "$HOME/.config")
                   ("XDG_DATA_DIRS" . "$HOME/.local/share:$HOME/.local/share/flatpak/exports/share")
                   ("SBCL_HOME" . "$HOME/.guix-home/profile/lib/sbcl/")
                   ("GPG_TTY" . "$(tty)")
                   ("PATH" . "$HOME/bin:$HOME/.config/emacs/bin:$PATH")))
                (aliases
                 '(("ls" . "ls -aF --color=always")))
                (bashrc (list (local-file "files/.bashrc"
                                          "bashrc")))
                (bash-profile (list (local-file "files/.bash_profile"
                                                "bash_profile")))))

      (service home-files-service-type
               `((".guile" ,%default-dotguile)
                 (".Xdefaults" ,(local-file "files/Xdefaults"))
                 (".sbclrc" ,(local-file "files/sbclrc"))
                 ("quicklisp.lisp" ,(local-file "files/quicklisp.lisp"))
                 (".gitconfig" ,(local-file "files/gitconfig"))))

      (service home-xdg-configuration-files-service-type
               `(("gdb/gdbinit" ,%default-gdbinit)
                 ("stumpwm/config" ,(local-file "files/.stumpwm.d/init.lisp"))
                 ("alacritty/alacritty.toml" ,(local-file "files/alacritty.toml"))))

      (service home-dbus-service-type)

      (service home-pipewire-service-type)

      (service home-openssh-service-type
               (home-openssh-configuration
                (add-keys-to-agent "yes")
                (hosts
                 (list (openssh-host (name "dadpi")
                                     (host-name "dadpi.local")
                                     (user "dad")
                                     (identity-file "~/.ssh/id_rsa.pub")
                                     (extra-content "PreferredAuthentications publickey"))
                       (openssh-host (name "pihole")
                                     (host-name "pihole.local")
                                     (user "pi")
                                     (identity-file "~/.ssh/id_rsa.pub")
                                     (extra-content "PreferredAuthentications publickey"))
                       (openssh-host (name "pihole2")
                                     (host-name "pihole2.local")
                                     (user "pi")
                                     (identity-file "~/.ssh/id_rsa.pub")
                                     (extra-content "PreferredAuthentications publickey"))
                       (openssh-host (name "octopi")
                                     (host-name "octopi.local")
                                     (identity-file "~/.ssh/id_rsa.pub")
                                     (extra-content "PreferredAuthentications publickey"))))))

      (service home-gpg-agent-service-type
               (home-gpg-agent-configuration
                (pinentry-program
                 (file-append pinentry "$HOME/.guix-home/profile/bin/pinentry"))
                (ssh-support? #t))))
     %base-home-services))))

home-config
