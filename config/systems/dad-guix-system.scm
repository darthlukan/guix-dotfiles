(use-modules (gnu)
             (gnu services)
             (guix)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (gnu system accounts)
             (gnu system nss))
(use-package-modules wm)
(use-service-modules containers
                     cups
                     desktop
                     networking
                     ssh
                     xorg)

(operating-system
 (locale "en_US.utf8")
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (timezone "America/Los_Angeles")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "dad-guix")
 ;; Bootloader config
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
                       (device (uuid "3527a79f-ff4c-4a8f-a11e-188ced67539d" 'ext4))
                       (type "ext4"))
                      (file-system
                       (mount-point "/boot/efi")
                       (device (uuid "5894-B18E" 'fat32))
                       (type "vfat")) %base-file-systems))
 ;; Additional Groups for our user
 (groups (cons* (user-group
                 (name "pipewire")
                 (system? #t))
                (cons* (user-group
                        (name "cgroup")
                        (system? #t)) %base-groups)))
 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
                (name "dad")
                (comment "Brian Tomlinson")
                (group "users")
                (home-directory "/home/dad")
                (supplementary-groups '("wheel"
                                        "netdev"
                                        "audio"
                                        "video"
                                        "dialout"
                                        "disk"
                                        "pipewire"
                                        "input"
                                        "cgroup")))
               %base-user-accounts))

 ;; Packages installed system-wide.  Users can also install packages
 ;; under their own account: use 'guix search KEYWORD' to search
 ;; for packages and 'guix install PACKAGE' to install a package.
 (packages (append (specifications->packages (list "sway"
                                                   "sbcl"
                                                   "stumpwm"
                                                   "font-dejavu"
                                                   "wmenu"
                                                   "foot"
                                                   "qutebrowser"
                                                   "git"
                                                   "vim"
                                                   "vim-guix-vim"
                                                   "fd"
                                                   "shellcheck"
                                                   "markdown"
                                                   "emacs"
                                                   "emacs-guix"
                                                   "ranger"
                                                   "pcmanfm"
                                                   "conmon"
                                                   "netavark"
                                                   "podman"
                                                   "podman-compose"))
                   %base-packages))
 ;; Below is the list of system services.  To search for available
 ;; services, run 'guix system search KEYWORD' in a terminal.
 (services
  (append
   (list
    (service openssh-service-type)
    (service cups-service-type)
    (set-xorg-configuration
     (xorg-configuration (keyboard-layout keyboard-layout)))
    (service rootless-podman-service-type
             (rootless-podman-configuration
              (subgids (list (subid-range (name "dad"))))
              (subuids (list (subid-range (name "dad")))))))
   (modify-services %desktop-services
                    (guix-service-type config =>
                                       (guix-configuration
                                        (inherit config)
                                        (substitute-urls (append (list
                                                                  ;; "https://substitutes.nonguix.org"
                                                                  "https://cache-us-lax.guix.moe")
                                                                 %default-substitute-urls))
                                        (authorized-keys (append (list
                                                                  (local-file "./nonguix-signing-key.pub")
                                                                  (plain-file "guix-moe-old.pub" "(public-key (ecc (curve Ed25519) (q #374EC58F5F2EC0412431723AF2D527AD626B049D657B5633AAAEBC694F3E33F9#)))")
                                                                  (plain-file "guix-moe.pub" "(public-key (ecc (curve Ed25519) (q #552F670D5005D7EB6ACF05284A1066E52156B51D75DE3EBD3030CD046675D543#)))"))
                                                                 %default-authorized-guix-keys)))))))
 (name-service-switch %mdns-host-lookup-nss))
