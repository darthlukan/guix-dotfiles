(use-modules (gnu)
             (nongnu packages linux)
             (nongnu system linux-initrd))
(use-package-modules wm)
(use-service-modules cups desktop networking ssh xorg)

(operating-system
 (locale "en_US.utf8")
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (timezone "America/Los_Angeles")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "dad-guix")
 (groups (cons*
          (user-group
           (name "pipewire")
           (system? #t))
          %base-groups))

 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
                (name "dad")
                (comment "Brian Tomlinson")
                (group "users")
                (home-directory "/home/dad")
                (supplementary-groups '("wheel" "netdev" "audio" "video"
                                        "dialout" "disk" "pipewire" "input")))
               %base-user-accounts))

 ;; Packages installed system-wide.  Users can also install packages
 ;; under their own account: use 'guix search KEYWORD' to search
 ;; for packages and 'guix install PACKAGE' to install a package.
 (packages (append (list (specification->package "sway")
                         (specification->package "sbcl")
                         stumpwm
                         (specification->package "font-dejavu")
                         (specification->package "wmenu")
                         (specification->package "foot")
                         (specification->package "qutebrowser")
                         (specification->package "git")
                         (specification->package "vim")
                         (specification->package "vim-guix-vim")
                         (specification->package "fd")
                         (specification->package "shellcheck")
                         (specification->package "markdown")
                         (specification->package "emacs")
                         (specification->package "emacs-guix")
                         (specification->package "ranger")
                         (specification->package "pcmanfm")) %base-packages))

 ;; Below is the list of system services.  To search for available
 ;; services, run 'guix system search KEYWORD' in a terminal.
 (services
  (append (list
           ;; To configure OpenSSH, pass an 'openssh-configuration'
           ;; record as a second argument to 'service' below.
           (service openssh-service-type)
           (service cups-service-type)
           (set-xorg-configuration
            (xorg-configuration (keyboard-layout keyboard-layout))))

          ;; This works because it ultimately returns a list of services by
          ;; way of modifying %DESKTOP-SERVICES, which is a list of services.
          ;; Include `nonguix` substitutes.
          (modify-services %desktop-services
                           (guix-service-type
                            config =>
                            (guix-configuration
                             (inherit config)
                             (substitute-urls
                              (append
                               (list
                                "https://substitutes.nonguix.org")
                               %default-substitute-urls))
                             (authorized-keys
                              (append
                               (list
                                (local-file
                                 "./nonguix-signing-key.pub"))
                               %default-authorized-guix-keys)))))))

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets (list "/boot/efi"))
              (keyboard-layout keyboard-layout)))
 (swap-devices (list (swap-space
                      (target (uuid "10a7bd55-12f0-4b17-a287-21f3a49c42ff")))))
 ;; The list of file systems that get "mounted".  The unique
 ;; file system identifiers there ("UUIDs") can be obtained
 ;; by running 'blkid' in a terminal.
 (file-systems (cons* (file-system
                       (mount-point "/")
                       (device (uuid "3527a79f-ff4c-4a8f-a11e-188ced67539d"
                                     'ext4))
                       (type "ext4"))
                      (file-system
                       (mount-point "/boot/efi")
                       (device (uuid "5894-B18E"
                                     'fat32))
                       (type "vfat")) %base-file-systems)))
