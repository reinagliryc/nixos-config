{ config, pkgs, ... }:

{
  # Install Omarchy shell tools
  environment.systemPackages = with pkgs; [
    # Core shell tools
    starship       # Modern prompt
    zoxide         # Smarter cd command
    mise           # Runtime version manager (replaces asdf)
    fzf            # Fuzzy finder
    eza            # Modern ls replacement
    bat            # Cat with syntax highlighting
    
    # Optional tools used in Omarchy functions
    imagemagick    # For image transcoding functions
    ffmpeg         # For video transcoding functions
    exfatprogs     # For format-drive function
    parted         # For format-drive function
  ];

  # Configure bash
  programs.bash = {
    completion.enable = true;
    
    shellInit = ''
      # History control
      shopt -s histappend
      HISTCONTROL=ignoreboth
      HISTSIZE=32768
      HISTFILESIZE=32768
      
      # Ensure command hashing is off for mise
      set +h
    '';
    
    interactiveShellInit = ''
      # Initialize modern shell tools
      if command -v mise &> /dev/null; then
        eval "$(mise activate bash)"
      fi

      if command -v starship &> /dev/null; then
        eval "$(starship init bash)"
      fi

      if command -v zoxide &> /dev/null; then
        eval "$(zoxide init bash)"
      fi

      # FZF key bindings
      if command -v fzf &> /dev/null; then
        if [[ -f ${pkgs.fzf}/share/fzf/completion.bash ]]; then
          source ${pkgs.fzf}/share/fzf/completion.bash
        fi
        if [[ -f ${pkgs.fzf}/share/fzf/key-bindings.bash ]]; then
          source ${pkgs.fzf}/share/fzf/key-bindings.bash
        fi
      fi

      # Source Omarchy functions
      if [ -f /etc/bash/functions.sh ]; then
        source /etc/bash/functions.sh
      fi
    '';
    
    shellAliases = {
      # File system aliases (eza)
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "eza -lha --group-directories-first --icons=auto";
      lt = "eza --tree --level=2 --long --icons --git";
      lta = "eza --tree --level=2 --long --icons --git -a";
      
      # FZF with bat preview
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      
      # Tools
      d = "docker";
      r = "rails";
      
      # Git
      g = "git";
      gcm = "git commit -m";
      gcam = "git commit -a -m";
      gcad = "git commit -a --amend";
    };
  };

  # Environment variables
  environment.variables = {
    SUDO_EDITOR = "$EDITOR";
    BAT_THEME = "ansi";
  };

  # InputRC configuration for better readline
  environment.etc."inputrc".text = ''
    set meta-flag on
    set input-meta on
    set output-meta on
    set convert-meta off
    set completion-ignore-case on
    set completion-prefix-display-length 2
    set show-all-if-ambiguous on
    set show-all-if-unmodified on

    # Arrow keys match what you've typed so far against your command history
    "\e[A": history-search-backward
    "\e[B": history-search-forward
    "\e[C": forward-char
    "\e[D": backward-char

    # Immediately add a trailing slash when autocompleting symlinks to directories
    set mark-symlinked-directories on

    # Do not autocomplete hidden files unless the pattern explicitly begins with a dot
    set match-hidden-files off

    # Show all autocomplete results at once
    set page-completions off

    # If there are more than 200 possible completions for a word, ask to show them all
    set completion-query-items 200

    # Show extra file information when completing, like `ls -F` does
    set visible-stats on

    # Be more intelligent when autocompleting by also looking at the text after the cursor
    set skip-completed-text on

    # Coloring for Bash 4 tab completions
    set colored-stats on
  '';

  # Bash functions - these need to be in a separate file that gets sourced
  environment.etc."bash/functions.sh".text = ''
    # Compression
    compress() { tar -czf "''${1%/}.tar.gz" "''${1%/}"; }
    alias decompress="tar -xzf"

    # Smart cd with zoxide
    if command -v zoxide &> /dev/null; then
      zd() {
        if [ $# -eq 0 ]; then
          builtin cd ~ && return
        elif [ -d "$1" ]; then
          builtin cd "$1"
        else
          z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
        fi
      }
      alias cd="zd"
    fi

    # Open files with default application
    open() {
      xdg-open "$@" >/dev/null 2>&1 &
    }

    # Neovim wrapper
    n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

    # Write iso file to sd card
    iso2sd() {
      if [ $# -ne 2 ]; then
        echo "Usage: iso2sd <input_file> <output_device>"
        echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
        echo -e "\nAvailable SD cards:"
        lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
      else
        sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
        sudo eject $2
      fi
    }

    # Format an entire drive for a single partition using exFAT
    format-drive() {
      if [ $# -ne 2 ]; then
        echo "Usage: format-drive <device> <name>"
        echo "Example: format-drive /dev/sda 'My Stuff'"
        echo -e "\nAvailable drives:"
        lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
      else
        echo "WARNING: This will completely erase all data on $1 and label it '$2'."
        read -rp "Are you sure you want to continue? (y/N): " confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
          sudo wipefs -a "$1"
          sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
          sudo parted -s "$1" mklabel gpt
          sudo parted -s "$1" mkpart primary 1MiB 100%

          partition="$([[ $1 == *"nvme"* ]] && echo "''${1}p1" || echo "''${1}1")"
          sudo partprobe "$1" || true
          sudo udevadm settle || true

          sudo mkfs.exfat -n "$2" "$partition"

          echo "Drive $1 formatted as exFAT and labeled '$2'."
        fi
      fi
    }

    # Transcode a video to a good-balance 1080p that's great for sharing online
    transcode-video-1080p() {
      ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ''${1%.*}-1080p.mp4
    }

    # Transcode a video to a good-balance 4K that's great for sharing online
    transcode-video-4K() {
      ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ''${1%.*}-optimized.mp4
    }

    # Transcode any image to JPG image that's great for shrinking wallpapers
    img2jpg() {
      img="$1"
      shift
      magick "$img" $@ -quality 95 -strip ''${img%.*}-optimized.jpg
    }

    # Transcode any image to JPG image that's great for sharing online without being too big
    img2jpg-small() {
      img="$1"
      shift
      magick "$img" $@ -resize 1080x\> -quality 95 -strip ''${img%.*}-optimized.jpg
    }

    # Transcode any image to compressed-but-lossless PNG
    img2png() {
      img="$1"
      shift
      magick "$img" $@ -strip -define png:compression-filter=5 \
        -define png:compression-level=9 \
        -define png:compression-strategy=1 \
        -define png:exclude-chunk=all \
        "''${img%.*}-optimized.png"
    }
  '';

  # Set bash as default shell
  users.defaultUserShell = pkgs.bash;
}
