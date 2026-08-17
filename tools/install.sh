#!/usr/bin/env bash
# VoidLinux-Guide interactive installer.
# Run from an official Void Linux live image. Read tools/README.md and run --dry-run first.
set -Eeuo pipefail
IFS=$'\n\t'

INSTALLER_VERSION="P1-2026.08"
SCRIPT_NAME="${0##*/}"
REPO_BASE="https://repo-default.voidlinux.org"
OFFICIAL_MIRROR_HOSTS=(repo-default.voidlinux.org repo-de.voidlinux.org repo-fi.voidlinux.org repo-fr.voidlinux.org)
REPO_URL=""
TARGET_ROOT="/mnt/voidlinux-guide"
TARGET_DISK=""
TARGET_ARCH="auto"
TARGET_LIBC="glibc"
BOOT_MODE="auto"
PARTITION_LAYOUT="single-root"
ROOT_SIZE_GIB="32"
SWAP_SIZE_GIB="4"
ESP_SIZE_MIB="512"
BOOT_SIZE_GIB="2"
TARGET_MIRROR_URL=""
DRY_RUN=0
NON_INTERACTIVE=0
CONFIG_FILE=""
CONFIG_LOADED=0
RESUME_FILE=""
RECOVERY_FILE=""
RESUMING=0
RECOVERING=0
CONFIRM_TOKEN=""
STATE_FILE=""
COMPLETED_STEPS=""

ENCRYPTION="none"
CRYPT_CIPHER="aes-xts-plain64"
CRYPT_KEY_SIZE="512"
CRYPT_PASSPHRASE=""
VG_NAME="voidvm"
ROOT_LV_NAME="root"
HOME_LV_NAME="home"
SWAP_LV_NAME="swap"
ROOT_CRYPT_NAME="voidroot"
HOME_CRYPT_NAME="voidhome"
HOME_CRYPT_PASSPHRASE=""

TARGET_USER="voiduser"
ROOT_PASSWORD=""
USER_PASSWORD=""
GENERATE_ROOT_PROFILE=1
GENERATE_USER_PROFILE=1
SHOW_QR=0

DESKTOP="none"
DISPLAY_PROTOCOL="auto"
SESSION_MANAGER="auto"
GPU="auto"
NETWORK_MANAGER=0
FIREWALL="none"
APPARMOR=0
ENABLE_SSH=0
TIMEZONE="UTC"
LOCALE="en_US.UTF-8"
HOSTNAME_VALUE="void"

ESP_DEV=""
DATA_DEV=""
ROOT_DEV=""
HOME_DEV=""
SWAP_DEV=""
CRYPT_UUID=""
HOME_CRYPT_UUID=""
BOOT_DEV=""
ROOT_DATA_DEV=""
HOME_DATA_DEV=""
BACKUP_DIR=""
TPM2_MODE="off"
FIDO2_MODE="off"
SECURE_BOOT_MODE="off"

RED="\033[31m"; YELLOW="\033[33m"; BLUE="\033[34m"; RESET="\033[0m"

usage() {
  cat <<USAGE
Usage: $SCRIPT_NAME [OPTIONS]

Interactive installer for native Void Linux targets. Supported targets:
  x86_64 glibc, x86_64 musl, aarch64 glibc, aarch64 musl.

Options:
  --dry-run             Render the plan without modifying disks, packages, services or secrets.
  --config FILE         Load a reviewed shell-style configuration file.
        --resume FILE         Resume an incomplete installation from a private state file.
      --recover FILE        Mount a recorded target and write a non-destructive recovery report.

  --non-interactive     Require config/resume values and CONFIRM_TOKEN=VOID_INSTALL for real execution.
  --target-root DIR     Staging root, default: /mnt/voidlinux-guide.
        --repo URL            Official Void repository URL; normally derived from target arch/libc.
      --mirror URL          Official mirror base or repository URL; validated before bootstrap.

  -h, --help            Show this help.

The script uses the official XBPS bootstrap method. A real run can erase an entire
whole-disk target. Run --dry-run, inspect the disk report, and review the final
plan before executing on a disposable or confirmed target disk.
USAGE
}

log() { printf '%b\n' "${BLUE}==>${RESET} $*"; }
warn() { printf '%b\n' "${YELLOW}Warning:${RESET} $*" >&2; }
die() { printf '%b\n' "${RED}Error:${RESET} $*" >&2; exit 1; }

run() {
  if (( DRY_RUN )); then
    printf '%b' "${YELLOW}[dry-run]${RESET}"
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

run_shell() {
  if (( DRY_RUN )); then
    printf '%b\n' "${YELLOW}[dry-run]${RESET} $*"
  else
    bash -c "$*"
  fi
}

require_command() { command -v "$1" >/dev/null 2>&1 || die "Required command is missing: $1"; }

parse_args() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --config) (($# >= 2)) || die "--config requires a file"; CONFIG_FILE="$2"; shift ;;
      --resume) (($# >= 2)) || die "--resume requires a state file"; RESUME_FILE="$2"; shift ;;
      --recover) (($# >= 2)) || die "--recover requires a state file"; RECOVERY_FILE="$2"; shift ;;
      --non-interactive) NON_INTERACTIVE=1 ;;
      --target-root) (($# >= 2)) || die "--target-root requires a directory"; TARGET_ROOT="$2"; shift ;;
      --repo) (($# >= 2)) || die "--repo requires a URL"; REPO_URL="$2"; shift ;;
      --mirror) (($# >= 2)) || die "--mirror requires a URL"; TARGET_MIRROR_URL="$2"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown option: $1" ;;
    esac
    shift
  done
  [[ -z "$CONFIG_FILE" || -z "$RESUME_FILE" ]] || die "Use either --config or --resume, not both"
  [[ -z "$RECOVERY_FILE" || ( -z "$CONFIG_FILE" && -z "$RESUME_FILE" ) ]] || die "--recover cannot be combined with --config or --resume"
}

load_config() {
  [[ -n "$CONFIG_FILE" ]] || return 0
  [[ -r "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || die "Cannot read configuration file: $CONFIG_FILE"
  # A config is intentionally shell syntax and must be reviewed by the operator.
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
  CONFIG_LOADED=1
}

state_variables() {
  cat <<'VARS'
TARGET_ROOT TARGET_DISK TARGET_ARCH TARGET_LIBC BOOT_MODE PARTITION_LAYOUT ROOT_SIZE_GIB SWAP_SIZE_GIB ESP_SIZE_MIB BOOT_SIZE_GIB REPO_URL TARGET_MIRROR_URL ENCRYPTION CRYPT_CIPHER CRYPT_KEY_SIZE VG_NAME ROOT_LV_NAME HOME_LV_NAME SWAP_LV_NAME ROOT_CRYPT_NAME HOME_CRYPT_NAME TARGET_USER GENERATE_ROOT_PROFILE GENERATE_USER_PROFILE SHOW_QR DESKTOP DISPLAY_PROTOCOL SESSION_MANAGER GPU NETWORK_MANAGER FIREWALL APPARMOR ENABLE_SSH TIMEZONE LOCALE HOSTNAME_VALUE ESP_DEV BOOT_DEV DATA_DEV ROOT_DATA_DEV HOME_DATA_DEV ROOT_DEV HOME_DEV SWAP_DEV CRYPT_UUID HOME_CRYPT_UUID BACKUP_DIR TPM2_MODE FIDO2_MODE SECURE_BOOT_MODE COMPLETED_STEPS STATE_FILE
VARS
}

state_file_default() {
  if [[ -n "$STATE_FILE" ]]; then return 0; fi
  STATE_FILE="/run/voidlinux-guide-installer/$(basename "$TARGET_DISK").state"
}

save_state() {
  if (( DRY_RUN )); then
    printf '%b\n' "${YELLOW}[dry-run]${RESET} save state $STATE_FILE"
    return 0
  fi
  state_file_default
  local directory temporary variable
  directory="$(dirname "$STATE_FILE")"
  mkdir -p "$directory"
  chmod 0700 "$directory"
  temporary="${STATE_FILE}.tmp.$$"
  umask 077
  {
    printf '# VoidLinux-Guide private resumable state. No passwords or LUKS passphrase.\n'
    printf 'STATE_INSTALLER_VERSION=%q\n' "$INSTALLER_VERSION"
    while read -r variable; do
      [[ -n "$variable" ]] || continue
      printf '%s=%q\n' "$variable" "${!variable}"
    done < <(state_variables | tr ' ' '\n')
  } > "$temporary"
  chmod 0600 "$temporary"
  mv -f "$temporary" "$STATE_FILE"
}

validate_state_file() {
  [[ -f "$STATE_FILE" && -r "$STATE_FILE" ]] || die "Cannot read resume state: $STATE_FILE"
  [[ "$(stat -c '%u' "$STATE_FILE")" == "0" ]] || die "Resume state must be owned by root"
  [[ "$(stat -c '%a' "$STATE_FILE")" == "600" ]] || die "Resume state must have mode 0600"
}

load_state() {
  [[ -n "$RESUME_FILE" ]] || return 0
  STATE_FILE="$RESUME_FILE"
  validate_state_file
  local runtime_version="$INSTALLER_VERSION"
  # State files are created by save_state and use shell-escaped assignments.
  # shellcheck disable=SC1090
  source "$STATE_FILE"
  [[ "${STATE_INSTALLER_VERSION:-}" == "$runtime_version" ]] || die "State file was created by a different installer version"
  [[ -n "$TARGET_DISK" && -n "$COMPLETED_STEPS" ]] || die "Incomplete or invalid state file"
  RESUMING=1
  log "Resuming target $TARGET_DISK from $STATE_FILE"
}

load_recovery_state() {
  [[ -n "$RECOVERY_FILE" ]] || return 0
  STATE_FILE="$RECOVERY_FILE"
  validate_state_file
  local runtime_version="$INSTALLER_VERSION"
  # State files are generated by this installer and contain shell-escaped, non-secret values.
  # shellcheck disable=SC1090
  source "$STATE_FILE"
  [[ "${STATE_INSTALLER_VERSION:-}" == "$runtime_version" ]] || die "Recovery state was created by a different installer version"
  [[ -n "$TARGET_DISK" && -n "$COMPLETED_STEPS" ]] || die "Incomplete or invalid recovery state file"
  RECOVERING=1
  log "Preparing non-destructive recovery for $TARGET_DISK from $STATE_FILE"
}

step_done() { [[ ",$COMPLETED_STEPS," == *",$1,"* ]]; }
mark_step() {
  local step="$1"
  step_done "$step" && return
  if [[ -z "$COMPLETED_STEPS" ]]; then COMPLETED_STEPS="$step"; else COMPLETED_STEPS+=",$step"; fi
  save_state
}

run_stage() {
  local step="$1" function="$2"
  if step_done "$step"; then
    log "Skipping completed stage: $step"
    return
  fi
  log "Running stage: $step"
  "$function"
  mark_step "$step"
}

check_host() {
  if (( DRY_RUN )); then return 0; fi
  (( EUID == 0 )) || die "Run as root from an official Void live image. Use --dry-run for safe planning."
  [[ -r /etc/os-release ]] || die "Cannot identify host OS"
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == "void" ]] || die "Real installation requires a Void Linux host; detected: ${ID:-unknown}"
}

check_dependencies() {
  local commands=(awk basename blkid chmod cp cut date df findmnt grep head ln lsblk mkdir mount mv pgrep printf rm sed sha256sum sort stat sync tee tr umount)
  if (( ! DRY_RUN )); then
    commands+=(xbps-install sfdisk partprobe mkfs.ext4 mkfs.vfat mkswap swapon swapoff cryptsetup pvcreate vgcreate vgchange lvcreate grub-install grub-mkconfig chroot wipefs)
  fi
  local command
  for command in "${commands[@]}"; do require_command "$command"; done
}

ask() {
  local prompt="$1" default="${2:-}"
  (( ! NON_INTERACTIVE )) || die "Missing non-interactive value for: $prompt"
  if [[ -n "$default" ]]; then read -r -p "$prompt [$default]: " REPLY; REPLY="${REPLY:-$default}"; else read -r -p "$prompt: " REPLY; fi
  printf '%s' "$REPLY"
}

choose() {
  local prompt="$1"; shift
  local options=("$@") answer i
  printf '\n%s\n' "$prompt" >&2
  for i in "${!options[@]}"; do printf '  %d) %s\n' "$((i+1))" "${options[$i]}" >&2; done
  (( ! NON_INTERACTIVE )) || die "Choice required in non-interactive mode: $prompt"
  while true; do
    read -r -p "Select [1-${#options[@]}]: " answer
    [[ "$answer" =~ ^[0-9]+$ ]] && (( answer >= 1 && answer <= ${#options[@]} )) && { printf '%s' "${options[$((answer-1))]}"; return; }
    warn "Select a number from 1 to ${#options[@]}."
  done
}

confirm() {
  local prompt="$1" answer target_name
  if (( NON_INTERACTIVE )); then [[ "$CONFIRM_TOKEN" == "VOID_INSTALL" ]] || die "Non-interactive real execution requires CONFIRM_TOKEN=VOID_INSTALL"; return; fi
  read -r -p "$prompt Type YES to continue: " answer
  [[ "$answer" == "YES" ]] || die "Confirmation not received"
  target_name="$(basename "$TARGET_DISK")"
  read -r -p "Type target disk basename '$target_name' to confirm: " answer
  [[ "$answer" == "$target_name" ]] || die "Target-disk confirmation did not match"
}

random_password() { LC_ALL=C tr -dc 'A-Za-z0-9@%+=_.,:!?-' < /dev/urandom | dd bs=28 count=1 2>/dev/null; }

secure_password() {
  local label="$1" secret
  (( ! DRY_RUN )) || { printf '%s' '<generated-at-install-time>'; return; }
  if [[ "$label" == root && -n "$ROOT_PASSWORD" ]]; then printf '%s' "$ROOT_PASSWORD"; return; fi
  if [[ "$label" == user && -n "$USER_PASSWORD" ]]; then printf '%s' "$USER_PASSWORD"; return; fi
  secret="$(random_password)"
  [[ -n "$secret" ]] || die "Password generation failed"
  printf '%s' "$secret"
}

show_qr() {
  local secret="$1"
  if command -v qrencode >/dev/null 2>&1; then printf '%s' "$secret" | qrencode -t ANSIUTF8
  elif [[ -x "$TARGET_ROOT/usr/bin/qrencode" ]]; then printf '%s' "$secret" | chroot "$TARGET_ROOT" qrencode -t ANSIUTF8
  else warn "qrencode is unavailable; text output was used instead."; fi
}

show_secret() {
  local label="$1" secret="$2"
  printf '\n%b\n' "${RED}SECURITY WARNING${RESET}"
  printf '%s\n' "The $label password is displayed on this terminal. Cameras, screen sharing and terminal scrollback can capture it. Store it in a password manager and clear terminal scrollback afterwards."
  printf '%s\n' "Password: $secret"
  if (( SHOW_QR )); then printf '%s\n' "QR payload is the password only. Do not scan it in public."; show_qr "$secret"; fi
  (( NON_INTERACTIVE )) || read -r -p "Record the password, then press Enter to continue." _
}

part_path() {
  local disk="$1" number="$2"
  if [[ "$disk" =~ (nvme|mmcblk)[0-9]+$ ]]; then printf '%sp%s' "$disk" "$number"; else printf '%s%s' "$disk" "$number"; fi
}

is_positive_integer() { [[ "$1" =~ ^[1-9][0-9]*$ ]]; }

normalize_target() {
  if [[ "$TARGET_ARCH" == auto ]]; then TARGET_ARCH="$(uname -m)"; fi
  [[ "$TARGET_ARCH" == x86_64 || "$TARGET_ARCH" == aarch64 ]] || die "Supported target architectures are x86_64 and aarch64"
  [[ "$TARGET_LIBC" == glibc || "$TARGET_LIBC" == musl ]] || die "TARGET_LIBC must be glibc or musl"
  if [[ "$TARGET_ARCH" == x86_64 ]]; then
    if [[ "$TARGET_LIBC" == glibc ]]; then XBPS_TARGET="x86_64"; else XBPS_TARGET="x86_64-musl"; fi
  else
    if [[ "$TARGET_LIBC" == glibc ]]; then XBPS_TARGET="aarch64"; else XBPS_TARGET="aarch64-musl"; fi
  fi
  if [[ -z "$REPO_URL" ]]; then
    case "$XBPS_TARGET" in
      x86_64) REPO_URL="$REPO_BASE/current" ;;
      x86_64-musl) REPO_URL="$REPO_BASE/current/musl" ;;
      aarch64|aarch64-musl) REPO_URL="$REPO_BASE/current/aarch64" ;;
    esac
  fi
  if [[ "$BOOT_MODE" == auto ]]; then
    if [[ "$TARGET_ARCH" == aarch64 ]]; then BOOT_MODE=uefi
    elif [[ -d /sys/firmware/efi ]]; then BOOT_MODE=uefi
    else BOOT_MODE=bios; fi
  fi
  [[ "$BOOT_MODE" == uefi || "$BOOT_MODE" == bios ]] || die "BOOT_MODE must be uefi or bios"
  [[ "$TARGET_ARCH" != aarch64 || "$BOOT_MODE" == uefi ]] || die "Generic aarch64 route supports UEFI only"
  if (( ! DRY_RUN )) && [[ "$(uname -m)" != "$TARGET_ARCH" ]]; then
    die "Cross-architecture chroot is refused. Configure binfmt/QEMU separately for an incompatible host."
  fi
  normalize_mirror
}

repository_path() {
  case "$XBPS_TARGET" in
    x86_64) printf 'current' ;;
    x86_64-musl) printf 'current/musl' ;;
    aarch64|aarch64-musl) printf 'current/aarch64' ;;
    *) die "Cannot derive repository path for $XBPS_TARGET" ;;
  esac
}

repository_metadata_url() {
  printf '%s/%s-repodata' "${REPO_URL%/}" "$XBPS_TARGET"
}

mirror_host() {
  sed -E 's#^https://([^/]+).*$#\1#' <<< "$1"
}

is_allowed_mirror_host() {
  local host="$1" known
  for known in "${OFFICIAL_MIRROR_HOSTS[@]}"; do [[ "$host" == "$known" ]] && return 0; done
  return 1
}

normalize_mirror() {
  [[ -n "$TARGET_MIRROR_URL" ]] || return 0
  local base host path
  base="${TARGET_MIRROR_URL%/}"
  host="$(mirror_host "$base")"
  is_allowed_mirror_host "$host" || die "Mirror host is not in the built-in official allow-list: $host"
  path="$(repository_path)"
  if [[ "$base" == */current* ]]; then REPO_URL="$base"; else REPO_URL="$base/$path"; fi
}

network_preflight() {
  local metadata_url
  metadata_url="$(repository_metadata_url)"
  log "Network preflight: DNS and HTTPS reachability for $metadata_url"
  if (( DRY_RUN )); then
    printf '%b\n' "${YELLOW}[dry-run]${RESET} curl --fail --location --head --connect-timeout 10 --max-time 30 $metadata_url"
    return 0
  fi
  require_command curl
  curl --fail --location --head --connect-timeout 10 --max-time 30 "$metadata_url" >/dev/null || die "Network preflight failed for repository metadata; check network, DNS, time and mirror URL"
  log "Network preflight passed. XBPS signatures remain authoritative for package verification."
}

mirror_base_url() {
  local url="${TARGET_MIRROR_URL%/}"
  if [[ "$url" == */current* ]]; then printf '%s' "${url%%/current*}"; else printf '%s' "$url"; fi
}

configure_target_mirror() {
  [[ -n "$TARGET_MIRROR_URL" ]] || return 0
  local base; base="$(mirror_base_url)"
  log "Configuring target XBPS mirror override: $base"
  chroot_exec "mkdir -p /etc/xbps.d && cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/ && sed -i 's|https://repo-default.voidlinux.org|$base|g' /etc/xbps.d/*-repository-*.conf && xbps-install -S && xbps-query -L"
}

detect_gpu() {
  if [[ "$GPU" != auto ]]; then return 0; fi
  if (( DRY_RUN )) || ! command -v lspci >/dev/null 2>&1; then GPU=none; return; fi
  local pci; pci="$(lspci -nn | tr '[:upper:]' '[:lower:]')"
  case "$pci" in *amd*|*ati*) GPU=amd ;; *nvidia*) GPU=nvidia-nouveau ;; *intel*) GPU=intel ;; *) GPU=none ;; esac
}

normalize_desktop() {
  if [[ "$DESKTOP" != none ]]; then
    if [[ "$DISPLAY_PROTOCOL" == auto ]]; then
      case "$DESKTOP" in sway-wayland) DISPLAY_PROTOCOL=wayland ;; xfce-x11|i3-x11) DISPLAY_PROTOCOL=x11 ;; *) DISPLAY_PROTOCOL=wayland ;; esac
    fi
    if [[ "$SESSION_MANAGER" == auto ]]; then
      if [[ "$DESKTOP" == sway-wayland ]]; then SESSION_MANAGER=seatd; else SESSION_MANAGER=elogind; fi
    fi
  fi
}

select_options() {
  if (( RESUMING )); then normalize_target; normalize_desktop; return; fi
  if (( CONFIG_LOADED )); then
    [[ -n "$TARGET_DISK" && -n "$HOSTNAME_VALUE" && -n "$TARGET_USER" ]] || die "Config requires TARGET_DISK, HOSTNAME_VALUE and TARGET_USER"
    normalize_target; normalize_desktop
    if (( DRY_RUN )); then ROOT_PASSWORD='<generated-at-install-time>'; USER_PASSWORD='<generated-at-install-time>'; else ROOT_PASSWORD="$(secure_password root)"; USER_PASSWORD="$(secure_password user)"; fi
    return
  fi

  log "VoidLinux-Guide P0 interactive configuration"
  TARGET_ARCH="$(choose 'Target architecture' 'x86_64' 'aarch64')"
  TARGET_LIBC="$(choose 'Target libc' 'glibc' 'musl')"
  normalize_target
  HOSTNAME_VALUE="$(ask 'Hostname' "$HOSTNAME_VALUE")"
  TARGET_USER="$(ask 'Ordinary username' "$TARGET_USER")"
  TIMEZONE="$(ask 'Timezone (for example Europe/Moscow)' "$TIMEZONE")"
  if [[ "$TARGET_LIBC" == glibc ]]; then LOCALE="$(ask 'glibc locale' "$LOCALE")"; else LOCALE='C.UTF-8'; fi

  if (( DRY_RUN )); then TARGET_DISK='/dev/sdX'; else
    printf '\nAvailable whole disks:\n'; lsblk -d -o NAME,SIZE,MODEL,SERIAL,TRAN,ROTA,TYPE
    TARGET_DISK="$(ask 'Whole target disk (for example /dev/sda)')"
  fi
  if [[ "$BOOT_MODE" == auto ]]; then BOOT_MODE="$(choose 'Boot mode' 'uefi' 'bios')"; fi
  [[ "$TARGET_ARCH" != aarch64 || "$BOOT_MODE" == uefi ]] || die 'Generic aarch64 route requires UEFI'
  PARTITION_LAYOUT="$(choose 'Partition layout' 'single-root' 'root-home' 'root-home-swap' 'boot-encrypted-home')"
  if [[ "$PARTITION_LAYOUT" != single-root ]]; then ROOT_SIZE_GIB="$(ask 'Root size in GiB' "$ROOT_SIZE_GIB")"; fi
  if [[ "$PARTITION_LAYOUT" == root-home-swap || "$PARTITION_LAYOUT" == boot-encrypted-home ]]; then SWAP_SIZE_GIB="$(ask 'Swap size in GiB (use 0 for none)' "$SWAP_SIZE_GIB")"; fi
  if [[ "$PARTITION_LAYOUT" == boot-encrypted-home ]]; then
    BOOT_SIZE_GIB="$(ask 'Plain /boot size in GiB' "$BOOT_SIZE_GIB")"
    BOOT_MODE=uefi; ENCRYPTION=luks2-separate
    CRYPT_KEY_SIZE="$(choose 'LUKS2 AES-XTS key size' '256' '512')"; CRYPT_CIPHER='aes-xts-plain64'
    if (( DRY_RUN )); then
      CRYPT_PASSPHRASE='<entered-root-passphrase>'; HOME_CRYPT_PASSPHRASE='<entered-home-passphrase>'
    else
      local confirm_root confirm_home
      read -r -s -p 'LUKS2 root passphrase: ' CRYPT_PASSPHRASE; printf '\n'
      read -r -s -p 'Repeat LUKS2 root passphrase: ' confirm_root; printf '\n'
      [[ -n "$CRYPT_PASSPHRASE" && "$CRYPT_PASSPHRASE" == "$confirm_root" ]] || die 'LUKS2 root passphrases do not match'
      read -r -s -p 'LUKS2 home passphrase: ' HOME_CRYPT_PASSPHRASE; printf '\n'
      read -r -s -p 'Repeat LUKS2 home passphrase: ' confirm_home; printf '\n'
      [[ -n "$HOME_CRYPT_PASSPHRASE" && "$HOME_CRYPT_PASSPHRASE" == "$confirm_home" ]] || die 'LUKS2 home passphrases do not match'
      unset confirm_root confirm_home
    fi
  else
    ENCRYPTION="$(choose 'Encrypt root/home/swap with LUKS1 and LVM?' 'none' 'luks1-lvm')"
    if [[ "$ENCRYPTION" == luks1-lvm ]]; then
      CRYPT_KEY_SIZE="$(choose 'LUKS AES-XTS key size' '256' '512')"; CRYPT_CIPHER='aes-xts-plain64'
      if (( DRY_RUN )); then CRYPT_PASSPHRASE='<entered-at-install-time>'; else
        local confirm_pass
        read -r -s -p 'LUKS passphrase: ' CRYPT_PASSPHRASE; printf '\n'
        read -r -s -p 'Repeat LUKS passphrase: ' confirm_pass; printf '\n'
        [[ -n "$CRYPT_PASSPHRASE" && "$CRYPT_PASSPHRASE" == "$confirm_pass" ]] || die 'LUKS passphrases do not match'
        unset confirm_pass
      fi
    fi
  fi

  DESKTOP="$(choose 'Desktop or window-manager profile' 'none' 'gnome' 'kde-plasma' 'xfce-x11' 'sway-wayland' 'i3-x11')"
  if [[ "$DESKTOP" != none ]]; then
    case "$DESKTOP" in gnome|kde-plasma|sway-wayland) DISPLAY_PROTOCOL="$(choose 'Display protocol' 'wayland' 'x11')" ;; *) DISPLAY_PROTOCOL=x11 ;; esac
    case "$DESKTOP" in sway-wayland) SESSION_MANAGER=seatd ;; *) SESSION_MANAGER=elogind ;; esac
  fi
  GPU="$(choose 'GPU driver path' 'auto' 'none' 'amd' 'intel' 'nvidia-nouveau' 'nvidia-proprietary')"
  if [[ "$GPU" == nvidia-proprietary ]]; then GPU="$(choose 'NVIDIA package family' 'nvidia' 'nvidia580' 'nvidia470' 'nvidia390')"; fi
  NETWORK_MANAGER="$(choose 'Install and enable NetworkManager?' 'no' 'yes')"; [[ "$NETWORK_MANAGER" == yes ]] && NETWORK_MANAGER=1 || NETWORK_MANAGER=0
  FIREWALL="$(choose 'Firewall policy' 'none' 'nftables')"
  APPARMOR="$(choose 'Install and enable AppArmor kernel policy?' 'no' 'yes')"; [[ "$APPARMOR" == yes ]] && APPARMOR=1 || APPARMOR=0
  ENABLE_SSH="$(choose 'Install and enable OpenSSH server?' 'no' 'yes')"; [[ "$ENABLE_SSH" == yes ]] && ENABLE_SSH=1 || ENABLE_SSH=0
  GENERATE_ROOT_PROFILE="$(choose 'Generate a hardened root profile?' 'yes' 'no')"; [[ "$GENERATE_ROOT_PROFILE" == yes ]] && GENERATE_ROOT_PROFILE=1 || GENERATE_ROOT_PROFILE=0
  GENERATE_USER_PROFILE="$(choose 'Generate a non-root profile?' 'yes' 'no')"; [[ "$GENERATE_USER_PROFILE" == yes ]] && GENERATE_USER_PROFILE=1 || GENERATE_USER_PROFILE=0
  SHOW_QR="$(choose 'Display generated passwords as terminal QR when qrencode exists?' 'no' 'yes')"; [[ "$SHOW_QR" == yes ]] && SHOW_QR=1 || SHOW_QR=0
  if [[ "$PARTITION_LAYOUT" == boot-encrypted-home ]]; then
    TPM2_MODE="$(choose 'TPM2 mode (passphrases remain required recovery access)' 'off' 'check' 'clevis-tpm2')"
    FIDO2_MODE="$(choose 'FIDO2 mode (readiness only; no automatic enrollment)' 'off' 'check')"
    SECURE_BOOT_MODE="$(choose 'Secure Boot mode (prepare does not enroll firmware keys)' 'off' 'check' 'prepare')"
  fi
  if (( DRY_RUN )); then ROOT_PASSWORD='<generated-at-install-time>'; USER_PASSWORD='<generated-at-install-time>'; else ROOT_PASSWORD="$(secure_password root)"; USER_PASSWORD="$(secure_password user)"; fi
}

validate_inputs() {
  [[ "$TARGET_USER" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || die "Invalid ordinary username"
  [[ "$HOSTNAME_VALUE" =~ ^[A-Za-z0-9][A-Za-z0-9.-]{0,62}$ ]] || die "Invalid hostname"
  [[ "$TIMEZONE" =~ ^[A-Za-z0-9._+/-]+$ ]] || die "Invalid timezone"
  [[ "$LOCALE" =~ ^[A-Za-z0-9_.@-]+$ ]] || die "Invalid locale"
  [[ "$TARGET_ROOT" =~ ^/mnt/[A-Za-z0-9._/-]+$ ]] || die "Target root must be a simple /mnt path"
  [[ "$REPO_URL" =~ ^https://[a-z0-9.-]*voidlinux\.org/ ]] || die "Repository must be an official Void HTTPS repository"
  [[ -z "$TARGET_MIRROR_URL" || "$TARGET_MIRROR_URL" =~ ^https://[a-z0-9.-]*voidlinux\.org(/.*)?$ ]] || die "Mirror must be an official Void HTTPS URL"
  [[ "$ENCRYPTION" == none || "$ENCRYPTION" == luks1-lvm || "$ENCRYPTION" == luks2-separate ]] || die "Invalid encryption mode"
  [[ "$PARTITION_LAYOUT" =~ ^(single-root|root-home|root-home-swap|boot-encrypted-home)$ ]] || die "Invalid partition layout"
  [[ "$DESKTOP" =~ ^(none|gnome|kde-plasma|xfce-x11|sway-wayland|i3-x11)$ ]] || die "Invalid desktop choice"
  [[ "$DISPLAY_PROTOCOL" == auto || "$DISPLAY_PROTOCOL" == x11 || "$DISPLAY_PROTOCOL" == wayland ]] || die "Invalid display protocol"
  [[ "$SESSION_MANAGER" == auto || "$SESSION_MANAGER" == elogind || "$SESSION_MANAGER" == seatd ]] || die "Invalid session manager"
  [[ "$GPU" =~ ^(auto|none|amd|intel|nvidia-nouveau|nvidia|nvidia580|nvidia470|nvidia390)$ ]] || die "Invalid GPU choice"
  [[ "$FIREWALL" == none || "$FIREWALL" == nftables ]] || die "Invalid firewall choice"
  [[ "$NETWORK_MANAGER" =~ ^[01]$ && "$APPARMOR" =~ ^[01]$ && "$ENABLE_SSH" =~ ^[01]$ ]] || die "Security flags must be 0 or 1"
  is_positive_integer "$ESP_SIZE_MIB" || die "ESP_SIZE_MIB must be a positive integer"
  is_positive_integer "$BOOT_SIZE_GIB" || die "BOOT_SIZE_GIB must be a positive integer"
  if [[ "$PARTITION_LAYOUT" != single-root ]]; then is_positive_integer "$ROOT_SIZE_GIB" || die "ROOT_SIZE_GIB must be a positive integer"; fi
  if [[ "$PARTITION_LAYOUT" == root-home-swap ]]; then is_positive_integer "$SWAP_SIZE_GIB" || die "SWAP_SIZE_GIB must be a positive integer"; fi
  [[ "$TARGET_LIBC" != musl || ! "$GPU" =~ ^nvidia(580|470|390)?$ ]] || die "Proprietary NVIDIA is unsupported on musl targets"
  [[ "$TARGET_ARCH" != aarch64 || "$BOOT_MODE" == uefi ]] || die "Generic aarch64 route requires UEFI"
  [[ "$PARTITION_LAYOUT" != boot-encrypted-home || "$BOOT_MODE" == uefi ]] || die "boot-encrypted-home requires UEFI"
  [[ "$PARTITION_LAYOUT" != boot-encrypted-home || "$ENCRYPTION" == luks2-separate ]] || die "boot-encrypted-home requires luks2-separate"
  [[ "$ENCRYPTION" != luks2-separate || "$PARTITION_LAYOUT" == boot-encrypted-home ]] || die "luks2-separate is only supported by boot-encrypted-home"
  [[ "$TPM2_MODE" =~ ^(off|check|clevis-tpm2)$ ]] || die "TPM2_MODE must be off, check or clevis-tpm2"
  [[ "$FIDO2_MODE" =~ ^(off|check)$ ]] || die "FIDO2_MODE must be off or check"
  [[ "$SECURE_BOOT_MODE" =~ ^(off|check|prepare)$ ]] || die "SECURE_BOOT_MODE must be off, check or prepare"
  [[ "$SECURE_BOOT_MODE" == off || "$BOOT_MODE" == uefi ]] || die "Secure Boot requires UEFI"
  [[ "$SECURE_BOOT_MODE" == off || "$PARTITION_LAYOUT" == boot-encrypted-home ]] || die "Secure Boot prepare requires the separate /boot profile"
  [[ "$TPM2_MODE" == off || "$ENCRYPTION" == luks2-separate ]] || die "TPM2 mode requires the LUKS2 separate /boot profile"
  [[ "$FIDO2_MODE" == off || "$ENCRYPTION" == luks2-separate ]] || die "FIDO2 check requires the LUKS2 separate /boot profile"
  if [[ "$ENCRYPTION" != none && $CONFIG_LOADED -eq 1 && $DRY_RUN -eq 0 && -z "$CRYPT_PASSPHRASE" ]]; then die "Real encrypted config mode requires CRYPT_PASSPHRASE from a protected input method"; fi
  if [[ "$ENCRYPTION" == luks2-separate && $CONFIG_LOADED -eq 1 && $DRY_RUN -eq 0 && -z "$HOME_CRYPT_PASSPHRASE" ]]; then die "Real LUKS2 separate-home config requires HOME_CRYPT_PASSPHRASE through a protected input method"; fi
}

layout_required_gib() {
  local required=3
  if [[ "$BOOT_MODE" == uefi ]]; then required=$((required + 1)); fi
  if [[ "$PARTITION_LAYOUT" == boot-encrypted-home ]]; then
    required=$((required + BOOT_SIZE_GIB + ROOT_SIZE_GIB + SWAP_SIZE_GIB + 2))
  elif [[ "$PARTITION_LAYOUT" != single-root ]]; then
    required=$((required + ROOT_SIZE_GIB + 2))
    if [[ "$PARTITION_LAYOUT" == root-home-swap ]]; then required=$((required + SWAP_SIZE_GIB)); fi
  fi
  printf '%s' "$required"
}

hardware_security_preflight() {
  if [[ "$TPM2_MODE" != off ]]; then
    log "TPM2 readiness check requested: $TPM2_MODE"
    if (( DRY_RUN )); then
      printf '%b\n' "${YELLOW}[dry-run]${RESET} inspect /dev/tpmrm0 or /dev/tpm0 and run tpm2_getcap properties-fixed when available"
    elif [[ -e /dev/tpmrm0 || -e /dev/tpm0 ]]; then
      if command -v tpm2_getcap >/dev/null 2>&1; then tpm2_getcap properties-fixed >/dev/null || die "TPM2 device exists but capability query failed"; fi
      log "TPM2 device detected. Existing LUKS passphrases remain mandatory recovery access."
    else
      die "TPM2 mode was requested but no /dev/tpmrm0 or /dev/tpm0 device is available"
    fi
  fi
  if [[ "$FIDO2_MODE" == check ]]; then
    log "FIDO2 readiness check requested"
    if (( DRY_RUN )); then
      printf '%b\n' "${YELLOW}[dry-run]${RESET} inspect /dev/hidraw* and record libfido2 compatibility boundary"
    elif compgen -G '/dev/hidraw*' >/dev/null; then
      log "One or more HID raw devices are present; this is a readiness signal, not proof of hmac-secret support."
    else
      warn "No HID raw devices are present. FIDO2 readiness cannot be established from this live environment."
    fi
  fi
  if [[ "$SECURE_BOOT_MODE" != off ]]; then
    log "Secure Boot readiness check requested: $SECURE_BOOT_MODE"
    if (( DRY_RUN )); then
      printf '%b\n' "${YELLOW}[dry-run]${RESET} inspect /sys/firmware/efi/efivars and stage sbctl status/checklist"
    elif [[ -d /sys/firmware/efi/efivars ]]; then
      log "UEFI variable filesystem is available. Firmware key enrollment remains an explicit manual post-install action."
    else
      die "Secure Boot mode requires an EFI runtime environment with /sys/firmware/efi/efivars"
    fi
  fi
}

print_disk_report() {
  log "Read-only target disk report for $TARGET_DISK"
  if (( DRY_RUN )) && [[ ! -b "$TARGET_DISK" ]]; then
    printf '%s\n' "[dry-run] Placeholder target $TARGET_DISK; no real block-device report is available."
    return
  fi
  printf '%s\n' '--- disk identity ---'
  lsblk -d -o PATH,SIZE,MODEL,SERIAL,TRAN,ROTA,TYPE "$TARGET_DISK" || true
  printf '%s\n' '--- partition and filesystem view ---'
  lsblk -o PATH,SIZE,TYPE,FSTYPE,FSVER,LABEL,UUID,PARTLABEL,PARTTYPE,MOUNTPOINTS "$TARGET_DISK" || true
  printf '%s\n' '--- signatures (read-only) ---'
  wipefs -n "$TARGET_DISK" || true
  printf '%s\n' '--- mounted paths on target disk ---'
  findmnt -rn -S "$TARGET_DISK" || true
  findmnt -rn -S "${TARGET_DISK}"* || true
  printf '%s\n' '--- possible LVM/RAID metadata ---'
  if command -v pvs >/dev/null 2>&1; then pvs -o pv_name,vg_name,pv_size --noheadings 2>/dev/null || true; fi
  if command -v mdadm >/dev/null 2>&1; then mdadm --examine "$TARGET_DISK" 2>/dev/null || true; fi
}

host_root_disk() {
  local source parent
  source="$(findmnt -nr -o SOURCE / 2>/dev/null || true)"
  [[ "$source" == /dev/* ]] || return 0
  parent="$(lsblk -no PKNAME "$source" 2>/dev/null | head -n1 || true)"
  if [[ -n "$parent" ]]; then printf '/dev/%s' "$parent"; elif [[ "$(lsblk -no TYPE "$source" 2>/dev/null || true)" == disk ]]; then printf '%s' "$source"; fi
}

target_has_signatures() {
  (( DRY_RUN )) && return 1
  wipefs -n "$TARGET_DISK" 2>/dev/null | grep -qE 'TYPE|offset'
}

validate_target() {
  [[ "$TARGET_DISK" == /dev/* ]] || die "Target disk must be a /dev path"
  if (( DRY_RUN )); then return; fi
  [[ -b "$TARGET_DISK" ]] || die "Target is not a block device: $TARGET_DISK"
  [[ "$(lsblk -dn -o TYPE "$TARGET_DISK")" == disk ]] || die "Target must be a whole disk, not a partition"
  [[ "$TARGET_DISK" != /dev/loop* && "$TARGET_DISK" != /dev/ram* ]] || die "Refusing loop or ram device"
  local live_disk; live_disk="$(host_root_disk || true)"
  [[ -z "$live_disk" || "$live_disk" != "$TARGET_DISK" ]] || die "Refusing disk that hosts the current live root: $TARGET_DISK"
  if lsblk -nr -o MOUNTPOINTS "$TARGET_DISK" | grep -q '[^[:space:]]'; then die "Target disk or one of its partitions is mounted"; fi
  local size_bytes minimum_bytes
  size_bytes="$(lsblk -bdn -o SIZE "$TARGET_DISK")"
  minimum_bytes="$(( $(layout_required_gib) * 1024 * 1024 * 1024 ))"
  (( size_bytes >= minimum_bytes )) || die "Target disk is too small for the selected layout; need at least $(layout_required_gib) GiB"
}

confirm_existing_signatures() {
  if (( DRY_RUN )); then return 0; fi
  target_has_signatures || return
  warn "Existing filesystem, partition, RAID or LVM signatures were detected on $TARGET_DISK. They will be erased."
  if (( NON_INTERACTIVE )); then [[ "$CONFIRM_TOKEN" == VOID_INSTALL ]] || die "Existing signatures require CONFIRM_TOKEN=VOID_INSTALL"; return; fi
  local answer
  read -r -p "Type ERASE-SIGNATURES to acknowledge existing signatures: " answer
  [[ "$answer" == ERASE-SIGNATURES ]] || die "Existing signatures were not acknowledged"
}

package_list() {
  detect_gpu
  local packages=(base-system sudo xtools)
  [[ "$TARGET_ARCH" == aarch64 ]] && packages+=(linux)
  [[ "$DESKTOP" == none ]] || packages+=(dbus pipewire)
  [[ "$ENCRYPTION" == none ]] || packages+=(cryptsetup lvm2 dracut)
  [[ "$SHOW_QR" == 1 ]] && packages+=(qrencode)
  [[ "$NETWORK_MANAGER" == 1 ]] && packages+=(NetworkManager)
  [[ "$FIREWALL" == nftables ]] && packages+=(nftables runit-nftables)
  [[ "$APPARMOR" == 1 ]] && packages+=(apparmor)
  [[ "$ENABLE_SSH" == 1 ]] && packages+=(openssh)
  [[ "$TPM2_MODE" != off ]] && packages+=(tpm2-tools tpm2-tss)
  [[ "$TPM2_MODE" == clevis-tpm2 ]] && packages+=(clevis)
  [[ "$FIDO2_MODE" == check ]] && packages+=(libfido2)
  [[ "$SECURE_BOOT_MODE" == prepare ]] && packages+=(sbctl)
  case "$SESSION_MANAGER" in elogind) packages+=(elogind) ;; seatd) packages+=(seatd) ;; esac
  case "$GPU" in amd) packages+=(linux-firmware-amd mesa-dri) ;; intel|nvidia-nouveau) packages+=(mesa-dri) ;; nvidia|nvidia580|nvidia470|nvidia390) packages+=("$GPU") ;; esac
  case "$DESKTOP" in gnome) packages+=(gnome gdm) ;; kde-plasma) packages+=(kde-plasma kde-baseapps sddm) ;; xfce-x11) packages+=(xorg xfce4 lightdm) ;; sway-wayland) packages+=(sway xorg-server-xwayland) ;; i3-x11) packages+=(xorg i3 lightdm) ;; esac
  [[ "$DISPLAY_PROTOCOL" == x11 && "$DESKTOP" == gnome ]] && packages+=(xorg)
  [[ "$DISPLAY_PROTOCOL" == x11 && "$DESKTOP" == kde-plasma ]] && packages+=(xorg)
  printf '%s ' "${packages[@]}"
}

summary() {
  detect_gpu
  state_file_default
  cat <<SUMMARY

----- VoidLinux-Guide P1 installation plan -----
Installer:         $INSTALLER_VERSION
Target:            $TARGET_ARCH / $TARGET_LIBC ($XBPS_TARGET)
Repository:        $REPO_URL
Mirror override:    ${TARGET_MIRROR_URL:-none}
Target disk:       $TARGET_DISK
Boot mode:         $BOOT_MODE
Layout:            $PARTITION_LAYOUT (root ${ROOT_SIZE_GIB}GiB, boot ${BOOT_SIZE_GIB}GiB, swap ${SWAP_SIZE_GIB}GiB when applicable)
Target root:       $TARGET_ROOT
Encryption:        $ENCRYPTION${ENCRYPTION:+ ($CRYPT_CIPHER / key-size $CRYPT_KEY_SIZE)}
TPM2 / FIDO2:      $TPM2_MODE / $FIDO2_MODE
Secure Boot:       $SECURE_BOOT_MODE
State file:        $STATE_FILE
Hostname:          $HOSTNAME_VALUE
User:              $TARGET_USER
Locale/timezone:   $LOCALE / $TIMEZONE
Desktop:           $DESKTOP
Display/session:   $DISPLAY_PROTOCOL / $SESSION_MANAGER
GPU:               $GPU
NetworkManager:    $NETWORK_MANAGER
Firewall/AppArmor: $FIREWALL / $APPARMOR
OpenSSH:           $ENABLE_SSH
Packages:          $(package_list)
Backup directory:  ${BACKUP_DIR:-/root/voidlinux-guide-install-backup-<timestamp>}
--------------------------------------------------
SUMMARY
}

partition_spec() {
  if [[ "$PARTITION_LAYOUT" == boot-encrypted-home ]]; then
    printf 'label: gpt\n'
    printf ',%sM,U\n' "$ESP_SIZE_MIB"
    printf ',%sG,L\n' "$BOOT_SIZE_GIB"
    printf ',%sG,L\n' "$ROOT_SIZE_GIB"
    printf ',,L\n'
    if (( SWAP_SIZE_GIB > 0 )); then printf ',%sG,S\n' "$SWAP_SIZE_GIB"; fi
    return
  fi
  if [[ "$BOOT_MODE" == uefi ]]; then
    printf 'label: gpt\n'
    printf ',%sM,U\n' "$ESP_SIZE_MIB"
    if [[ "$ENCRYPTION" != none || "$PARTITION_LAYOUT" == single-root ]]; then printf ',,L\n'; return; fi
    printf ',%sG,L\n' "$ROOT_SIZE_GIB"
    if [[ "$PARTITION_LAYOUT" == root-home-swap ]]; then printf ',%sG,S\n' "$SWAP_SIZE_GIB"; fi
    printf ',,L\n'
  else
    printf 'label: dos\n'
    if [[ "$ENCRYPTION" != none || "$PARTITION_LAYOUT" == single-root ]]; then printf ',,83\n'; return; fi
    printf ',%sG,83\n' "$ROOT_SIZE_GIB"
    if [[ "$PARTITION_LAYOUT" == root-home-swap ]]; then printf ',%sG,82\n' "$SWAP_SIZE_GIB"; fi
    printf ',,83\n'
  fi
}

# Assign physical devices after creating the selected layout.
assign_layout_devices() {
  local base=1
  ESP_DEV=''; BOOT_DEV=''; DATA_DEV=''; ROOT_DATA_DEV=''; HOME_DATA_DEV=''; ROOT_DEV=''; HOME_DEV=''; SWAP_DEV=''
  if [[ "$PARTITION_LAYOUT" == boot-encrypted-home ]]; then
    ESP_DEV="$(part_path "$TARGET_DISK" 1)"
    BOOT_DEV="$(part_path "$TARGET_DISK" 2)"
    ROOT_DATA_DEV="$(part_path "$TARGET_DISK" 3)"
    HOME_DATA_DEV="$(part_path "$TARGET_DISK" 4)"
    if (( SWAP_SIZE_GIB > 0 )); then SWAP_DEV="$(part_path "$TARGET_DISK" 5)"; fi
    return
  fi
  if [[ "$BOOT_MODE" == uefi ]]; then ESP_DEV="$(part_path "$TARGET_DISK" 1)"; base=2; fi
  if [[ "$ENCRYPTION" != none ]]; then DATA_DEV="$(part_path "$TARGET_DISK" "$base")"; return; fi
  ROOT_DEV="$(part_path "$TARGET_DISK" "$base")"
  case "$PARTITION_LAYOUT" in
    single-root) ;;
    root-home) HOME_DEV="$(part_path "$TARGET_DISK" "$((base + 1))")" ;;
    root-home-swap) SWAP_DEV="$(part_path "$TARGET_DISK" "$((base + 1))")"; HOME_DEV="$(part_path "$TARGET_DISK" "$((base + 2))")" ;;
  esac
}

format_and_mount_plain() {
  run mkfs.ext4 -F "$ROOT_DEV"
  [[ -z "$HOME_DEV" ]] || run mkfs.ext4 -F "$HOME_DEV"
  [[ -z "$SWAP_DEV" ]] || { run mkswap "$SWAP_DEV"; run swapon "$SWAP_DEV"; }
  run mkdir -p "$TARGET_ROOT"
  run mount "$ROOT_DEV" "$TARGET_ROOT"
  if [[ -n "$HOME_DEV" ]]; then run mkdir -p "$TARGET_ROOT/home"; run mount "$HOME_DEV" "$TARGET_ROOT/home"; fi
  if [[ -n "$ESP_DEV" ]]; then run mkfs.vfat -F32 "$ESP_DEV"; run mkdir -p "$TARGET_ROOT/boot/efi"; run mount "$ESP_DEV" "$TARGET_ROOT/boot/efi"; fi
}

format_and_mount_encrypted() {
  if (( DRY_RUN )); then
    run cryptsetup luksFormat --type luks1 --cipher "$CRYPT_CIPHER" --key-size "$CRYPT_KEY_SIZE" "$DATA_DEV"
    run cryptsetup luksOpen "$DATA_DEV" "$VG_NAME"
    run pvcreate "/dev/mapper/$VG_NAME"; run vgcreate "$VG_NAME" "/dev/mapper/$VG_NAME"
    if [[ "$PARTITION_LAYOUT" == single-root ]]; then
      run lvcreate --name "$ROOT_LV_NAME" -l 100%FREE "$VG_NAME"
    else
      run lvcreate --name "$ROOT_LV_NAME" -L "${ROOT_SIZE_GIB}G" "$VG_NAME"
      if [[ "$PARTITION_LAYOUT" == root-home-swap ]]; then run lvcreate --name "$SWAP_LV_NAME" -L "${SWAP_SIZE_GIB}G" "$VG_NAME"; fi
      run lvcreate --name "$HOME_LV_NAME" -l 100%FREE "$VG_NAME"
    fi
  else
    printf '%s\n' "$CRYPT_PASSPHRASE" | cryptsetup luksFormat --batch-mode --type luks1 --cipher "$CRYPT_CIPHER" --key-size "$CRYPT_KEY_SIZE" "$DATA_DEV" -
    printf '%s\n' "$CRYPT_PASSPHRASE" | cryptsetup luksOpen "$DATA_DEV" "$VG_NAME" --key-file=-
    pvcreate "/dev/mapper/$VG_NAME"; vgcreate "$VG_NAME" "/dev/mapper/$VG_NAME"
    if [[ "$PARTITION_LAYOUT" == single-root ]]; then lvcreate --name "$ROOT_LV_NAME" -l 100%FREE "$VG_NAME"
    else
      lvcreate --name "$ROOT_LV_NAME" -L "${ROOT_SIZE_GIB}G" "$VG_NAME"
      [[ "$PARTITION_LAYOUT" != root-home-swap ]] || lvcreate --name "$SWAP_LV_NAME" -L "${SWAP_SIZE_GIB}G" "$VG_NAME"
      lvcreate --name "$HOME_LV_NAME" -l 100%FREE "$VG_NAME"
    fi
  fi
  ROOT_DEV="/dev/$VG_NAME/$ROOT_LV_NAME"
  [[ "$PARTITION_LAYOUT" == single-root ]] || HOME_DEV="/dev/$VG_NAME/$HOME_LV_NAME"
  [[ "$PARTITION_LAYOUT" == root-home-swap ]] && SWAP_DEV="/dev/$VG_NAME/$SWAP_LV_NAME"
  run mkfs.ext4 -F "$ROOT_DEV"
  [[ -z "$HOME_DEV" ]] || run mkfs.ext4 -F "$HOME_DEV"
  [[ -z "$SWAP_DEV" ]] || { run mkswap "$SWAP_DEV"; run swapon "$SWAP_DEV"; }
  run mkdir -p "$TARGET_ROOT"; run mount "$ROOT_DEV" "$TARGET_ROOT"
  if [[ -n "$HOME_DEV" ]]; then run mkdir -p "$TARGET_ROOT/home"; run mount "$HOME_DEV" "$TARGET_ROOT/home"; fi
  if [[ -n "$ESP_DEV" ]]; then run mkfs.vfat -F32 "$ESP_DEV"; run mkdir -p "$TARGET_ROOT/boot/efi"; run mount "$ESP_DEV" "$TARGET_ROOT/boot/efi"; fi
  if (( ! DRY_RUN )); then
    CRYPT_UUID="$(blkid -s UUID -o value "$DATA_DEV")"
    mkdir -p "$TARGET_ROOT/etc"
    printf '%s UUID=%s none luks\n' "$VG_NAME" "$CRYPT_UUID" > "$TARGET_ROOT/etc/crypttab"
  fi
}

format_and_mount_luks2_separate() {
  if (( DRY_RUN )); then
    run cryptsetup luksFormat --type luks2 --cipher "$CRYPT_CIPHER" --key-size "$CRYPT_KEY_SIZE" "$ROOT_DATA_DEV"
    run cryptsetup open "$ROOT_DATA_DEV" "$ROOT_CRYPT_NAME"
    run cryptsetup luksFormat --type luks2 --cipher "$CRYPT_CIPHER" --key-size "$CRYPT_KEY_SIZE" "$HOME_DATA_DEV"
    run cryptsetup open "$HOME_DATA_DEV" "$HOME_CRYPT_NAME"
  else
    printf '%s\n' "$CRYPT_PASSPHRASE" | cryptsetup luksFormat --batch-mode --type luks2 --cipher "$CRYPT_CIPHER" --key-size "$CRYPT_KEY_SIZE" "$ROOT_DATA_DEV" -
    printf '%s\n' "$CRYPT_PASSPHRASE" | cryptsetup open "$ROOT_DATA_DEV" "$ROOT_CRYPT_NAME" --key-file=-
    printf '%s\n' "$HOME_CRYPT_PASSPHRASE" | cryptsetup luksFormat --batch-mode --type luks2 --cipher "$CRYPT_CIPHER" --key-size "$CRYPT_KEY_SIZE" "$HOME_DATA_DEV" -
    printf '%s\n' "$HOME_CRYPT_PASSPHRASE" | cryptsetup open "$HOME_DATA_DEV" "$HOME_CRYPT_NAME" --key-file=-
  fi
  ROOT_DEV="/dev/mapper/$ROOT_CRYPT_NAME"
  HOME_DEV="/dev/mapper/$HOME_CRYPT_NAME"
  run mkfs.ext4 -F "$ROOT_DEV"; run mkfs.ext4 -F "$HOME_DEV"; run mkfs.ext4 -F "$BOOT_DEV"; run mkfs.vfat -F32 "$ESP_DEV"
  if [[ -n "$SWAP_DEV" ]]; then run mkswap "$SWAP_DEV"; run swapon "$SWAP_DEV"; fi
  run mkdir -p "$TARGET_ROOT"; run mount "$ROOT_DEV" "$TARGET_ROOT"
  run mkdir -p "$TARGET_ROOT/boot" "$TARGET_ROOT/boot/efi" "$TARGET_ROOT/home"
  run mount "$BOOT_DEV" "$TARGET_ROOT/boot"; run mount "$ESP_DEV" "$TARGET_ROOT/boot/efi"; run mount "$HOME_DEV" "$TARGET_ROOT/home"
  if (( DRY_RUN )); then
    CRYPT_UUID='<root-luks2-uuid>'; HOME_CRYPT_UUID='<home-luks2-uuid>'
  else
    CRYPT_UUID="$(blkid -s UUID -o value "$ROOT_DATA_DEV")"
    HOME_CRYPT_UUID="$(blkid -s UUID -o value "$HOME_DATA_DEV")"
    mkdir -p "$TARGET_ROOT/etc"
    {
      printf '%s UUID=%s none luks\n' "$ROOT_CRYPT_NAME" "$CRYPT_UUID"
      printf '%s UUID=%s none luks\n' "$HOME_CRYPT_NAME" "$HOME_CRYPT_UUID"
    } > "$TARGET_ROOT/etc/crypttab"
  fi
}

partition_target() {
  log "Creating $PARTITION_LAYOUT layout on $TARGET_DISK (destructive)"
  assign_layout_devices
  if (( DRY_RUN )); then run_shell "partition_spec | sfdisk --wipe always $TARGET_DISK"; else partition_spec | sfdisk --wipe always "$TARGET_DISK"; partprobe "$TARGET_DISK"; fi
  if [[ "$ENCRYPTION" == none ]]; then
    format_and_mount_plain
  elif [[ "$ENCRYPTION" == luks1-lvm ]]; then
    format_and_mount_encrypted
  else
    format_and_mount_luks2_separate
  fi
}

resume_open_and_mount() {
  step_done partition || return
  log "Mounting existing incomplete target for resume"
  if [[ "$ENCRYPTION" == luks1-lvm ]]; then
    if (( DRY_RUN )); then
      CRYPT_PASSPHRASE='<prompted-on-resume>'
    elif (( NON_INTERACTIVE )); then
      [[ -n "$CRYPT_PASSPHRASE" ]] || die "Non-interactive encrypted resume requires CRYPT_PASSPHRASE through a protected input method"
    else
      read -r -s -p 'LUKS passphrase for resume: ' CRYPT_PASSPHRASE
      printf '\n'
    fi
    run cryptsetup luksOpen "$DATA_DEV" "$VG_NAME"; run vgchange -ay "$VG_NAME"
  elif [[ "$ENCRYPTION" == luks2-separate ]]; then
    if (( DRY_RUN )); then
      CRYPT_PASSPHRASE='<prompted-root-passphrase>'; HOME_CRYPT_PASSPHRASE='<prompted-home-passphrase>'
    elif (( NON_INTERACTIVE )); then
      [[ -n "$CRYPT_PASSPHRASE" && -n "$HOME_CRYPT_PASSPHRASE" ]] || die "Non-interactive LUKS2 resume requires root and home passphrases through protected input"
    else
      read -r -s -p 'LUKS2 root passphrase for resume: ' CRYPT_PASSPHRASE; printf '\n'
      read -r -s -p 'LUKS2 home passphrase for resume: ' HOME_CRYPT_PASSPHRASE; printf '\n'
    fi
    run cryptsetup open "$ROOT_DATA_DEV" "$ROOT_CRYPT_NAME"; run cryptsetup open "$HOME_DATA_DEV" "$HOME_CRYPT_NAME"
  fi
  run mkdir -p "$TARGET_ROOT"
  run mount "$ROOT_DEV" "$TARGET_ROOT"
  if [[ -n "$BOOT_DEV" ]]; then run mkdir -p "$TARGET_ROOT/boot"; run mount "$BOOT_DEV" "$TARGET_ROOT/boot"; fi
  if [[ -n "$HOME_DEV" ]]; then run mkdir -p "$TARGET_ROOT/home"; run mount "$HOME_DEV" "$TARGET_ROOT/home"; fi
  if [[ -n "$ESP_DEV" ]]; then run mkdir -p "$TARGET_ROOT/boot/efi"; run mount "$ESP_DEV" "$TARGET_ROOT/boot/efi"; fi
  [[ -z "$SWAP_DEV" ]] || run swapon "$SWAP_DEV"
}

mount_chroot_api() {
  run mkdir -p "$TARGET_ROOT/dev" "$TARGET_ROOT/proc" "$TARGET_ROOT/sys" "$TARGET_ROOT/run"
  if (( DRY_RUN )); then
    run mount --rbind /dev "$TARGET_ROOT/dev"; run mount --make-rslave "$TARGET_ROOT/dev"
    run mount -t proc proc "$TARGET_ROOT/proc"
    run mount --rbind /sys "$TARGET_ROOT/sys"; run mount --make-rslave "$TARGET_ROOT/sys"
    run mount --rbind /run "$TARGET_ROOT/run"; run mount --make-rslave "$TARGET_ROOT/run"
  else
    mount --rbind /dev "$TARGET_ROOT/dev"; mount --make-rslave "$TARGET_ROOT/dev"
    mount -t proc proc "$TARGET_ROOT/proc"
    mount --rbind /sys "$TARGET_ROOT/sys"; mount --make-rslave "$TARGET_ROOT/sys"
    mount --rbind /run "$TARGET_ROOT/run"; mount --make-rslave "$TARGET_ROOT/run"
  fi
}

bootstrap_target() {
  log "Bootstrapping $XBPS_TARGET through the official XBPS repository"
  if (( DRY_RUN )); then
    run mkdir -p "$TARGET_ROOT/var/db/xbps/keys"; run cp -a /var/db/xbps/keys/. "$TARGET_ROOT/var/db/xbps/keys/"
  else
    mkdir -p "$TARGET_ROOT/var/db/xbps/keys"; cp -a /var/db/xbps/keys/. "$TARGET_ROOT/var/db/xbps/keys/"
  fi
  run env XBPS_ARCH="$XBPS_TARGET" xbps-install -S -r "$TARGET_ROOT" -R "$REPO_URL" base-system
}

write_target_file() {
  local path="$1"; shift
  if (( DRY_RUN )); then printf '%b\n' "${YELLOW}[dry-run]${RESET} write $TARGET_ROOT/$path"; cat
  else mkdir -p "$(dirname "$TARGET_ROOT/$path")"; cat > "$TARGET_ROOT/$path"; fi
}

chroot_exec() {
  if (( DRY_RUN )); then printf '%b\n' "${YELLOW}[dry-run]${RESET} chroot $TARGET_ROOT $*"; else chroot "$TARGET_ROOT" /bin/sh -c "$*"; fi
}

enable_service() {
  local service="$1"
  if (( DRY_RUN )); then run ln -s "/etc/sv/$service" "$TARGET_ROOT/var/service/"
  else mkdir -p "$TARGET_ROOT/var/service"; ln -s "/etc/sv/$service" "$TARGET_ROOT/var/service/" 2>/dev/null || true; fi
}

device_uuid() {
  if (( DRY_RUN )); then printf '<%s-uuid>' "$1"; else blkid -s UUID -o value "$1"; fi
}

configure_target() {
  log "Writing target configuration"
  write_target_file /etc/hostname <<EOF
$HOSTNAME_VALUE
EOF
  write_target_file /etc/locale.conf <<EOF
LANG=$LOCALE
EOF
  if (( DRY_RUN )); then run ln -sf "/usr/share/zoneinfo/$TIMEZONE" "$TARGET_ROOT/etc/localtime"; else ln -sf "/usr/share/zoneinfo/$TIMEZONE" "$TARGET_ROOT/etc/localtime"; fi
  local fstab_content root_uuid
  root_uuid="$(device_uuid "$ROOT_DEV")"
  fstab_content="UUID=$root_uuid / ext4 defaults 0 1"
  if [[ -n "$BOOT_DEV" ]]; then fstab_content+=$'\n'"UUID=$(device_uuid "$BOOT_DEV") /boot ext4 defaults 0 2"; fi
  if [[ -n "$HOME_DEV" ]]; then fstab_content+=$'\n'"UUID=$(device_uuid "$HOME_DEV") /home ext4 defaults 0 2"; fi
  if [[ -n "$SWAP_DEV" ]]; then fstab_content+=$'\n'"UUID=$(device_uuid "$SWAP_DEV") none swap defaults 0 0"; fi
  if [[ -n "$ESP_DEV" ]]; then fstab_content+=$'\n'"UUID=$(device_uuid "$ESP_DEV") /boot/efi vfat defaults 0 2"; fi
  write_target_file /etc/fstab <<< "$fstab_content"
  configure_target_mirror
  if [[ "$ENCRYPTION" == luks1-lvm ]]; then
    write_target_file /etc/dracut.conf.d/10-voidlinux-guide-crypt.conf <<'EOF'
add_dracutmodules+=" crypt lvm "
EOF
  elif [[ "$ENCRYPTION" == luks2-separate ]]; then
    write_target_file /etc/dracut.conf.d/10-voidlinux-guide-crypt.conf <<'EOF'
add_dracutmodules+=" crypt "
EOF
    write_target_file /etc/default/grub <<EOF
GRUB_CMDLINE_LINUX_DEFAULT="rd.luks.uuid=luks-$CRYPT_UUID root=/dev/mapper/$ROOT_CRYPT_NAME"
EOF
  fi
  write_target_file /etc/profile.d/voidlinux-guide.sh <<'EOF'
# Safe defaults generated by VoidLinux-Guide.
umask 077
export EDITOR="${EDITOR:-vi}"
EOF
  if (( GENERATE_ROOT_PROFILE )); then write_target_file /root/.profile <<'EOF'
# Generated by VoidLinux-Guide.
umask 077
export EDITOR="${EDITOR:-vi}"
alias ll='ls -alF'
EOF
  fi
  if (( GENERATE_USER_PROFILE )); then
    write_target_file "/home/$TARGET_USER/.profile" <<'EOF'
# Generated by VoidLinux-Guide.
umask 077
export EDITOR="${EDITOR:-vi}"
alias ll='ls -alF'
EOF
  fi
  if (( APPARMOR )); then
    if (( DRY_RUN )); then printf '%b\n' "${YELLOW}[dry-run]${RESET} ensure GRUB_CMDLINE_LINUX_DEFAULT contains apparmor=1 security=apparmor"
    else
      mkdir -p "$TARGET_ROOT/etc/default"; touch "$TARGET_ROOT/etc/default/grub"
      if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$TARGET_ROOT/etc/default/grub"; then sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor"/' "$TARGET_ROOT/etc/default/grub"
      else printf '%s\n' 'GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor"' >> "$TARGET_ROOT/etc/default/grub"; fi
    fi
  fi
  if [[ "$FIREWALL" == nftables ]]; then write_target_file /etc/nftables.conf <<'EOF'
flush ruleset
table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    iifname "lo" accept
    ct state established,related accept
    ip protocol icmp accept
    ip6 nexthdr icmpv6 accept
    udp sport 67 udp dport 68 accept
    udp sport 547 udp dport 546 accept
  }
  chain forward { type filter hook forward priority 0; policy drop; }
  chain output { type filter hook output priority 0; policy accept; }
}
EOF
  fi
}

install_target_packages() {
  local packages; packages="$(package_list)"
  log "Installing selected package groups"
  if [[ "$GPU" =~ ^nvidia(580|470|390)?$ ]]; then chroot_exec 'xbps-install -S void-repo-nonfree'; fi
  chroot_exec "xbps-install -S -u $packages"
  if [[ "$TARGET_LIBC" == glibc ]]; then chroot_exec 'xbps-reconfigure -f glibc-locales'; fi
  if [[ "$GPU" =~ ^nvidia(580|470|390)?$ ]]; then chroot_exec "xbps-reconfigure -f $GPU"; fi
}

configure_accounts() {
  log "Creating accounts and applying password policy"
  if (( DRY_RUN )); then
    chroot_exec "useradd -m -G wheel,users,audio,video,network -s /bin/bash $TARGET_USER"
    chroot_exec 'set root password from stdin'; chroot_exec "set $TARGET_USER password from stdin"
  else
    chroot_exec "useradd -m -G wheel,users,audio,video,network -s /bin/bash $TARGET_USER"
    if (( GENERATE_USER_PROFILE )); then chown "$TARGET_USER:$TARGET_USER" "$TARGET_ROOT/home/$TARGET_USER/.profile"; fi
    printf 'root:%s\n' "$ROOT_PASSWORD" | chroot "$TARGET_ROOT" chpasswd
    printf '%s:%s\n' "$TARGET_USER" "$USER_PASSWORD" | chroot "$TARGET_ROOT" chpasswd
    printf '%s\n' '%wheel ALL=(ALL) ALL' > "$TARGET_ROOT/etc/sudoers.d/10-wheel"; chmod 0440 "$TARGET_ROOT/etc/sudoers.d/10-wheel"
  fi
}

configure_services() {
  log "Enabling selected services"
  [[ "$DESKTOP" == none && "$NETWORK_MANAGER" == 0 && "$ENABLE_SSH" == 0 ]] || enable_service dbus
  [[ "$SESSION_MANAGER" == elogind ]] && enable_service elogind
  if [[ "$SESSION_MANAGER" == seatd ]]; then enable_service seatd; (( DRY_RUN )) || chroot "$TARGET_ROOT" usermod -aG _seatd "$TARGET_USER"; fi
  (( NETWORK_MANAGER )) && enable_service NetworkManager
  [[ "$FIREWALL" == nftables ]] && enable_service nftables
  if (( ENABLE_SSH )); then
    enable_service sshd
    if (( ! DRY_RUN )); then grep -q '^PermitRootLogin' "$TARGET_ROOT/etc/ssh/sshd_config" 2>/dev/null && sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$TARGET_ROOT/etc/ssh/sshd_config" || printf '\nPermitRootLogin no\n' >> "$TARGET_ROOT/etc/ssh/sshd_config"; fi
  fi
  case "$DESKTOP" in gnome) enable_service gdm ;; kde-plasma) enable_service sddm ;; xfce-x11|i3-x11) enable_service lightdm ;; esac
}

install_bootloader() {
  log "Installing and configuring GRUB"
  if [[ "$BOOT_MODE" == uefi ]]; then
    if [[ "$TARGET_ARCH" == x86_64 ]]; then chroot_exec 'xbps-install -S grub-x86_64-efi efibootmgr'; chroot_exec 'grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Void'
    else chroot_exec 'xbps-install -S grub-arm64-efi efibootmgr'; chroot_exec 'grub-install --target=arm64-efi --efi-directory=/boot/efi --bootloader-id=Void'; fi
  else
    chroot_exec 'xbps-install -S grub'; chroot_exec "grub-install $TARGET_DISK"
  fi
  chroot_exec 'xbps-reconfigure -fa'; chroot_exec 'grub-mkconfig -o /boot/grub/grub.cfg'
}

configure_hardware_security() {
  local handoff_dir
  [[ "$TPM2_MODE" != off || "$FIDO2_MODE" != off || "$SECURE_BOOT_MODE" != off ]] || return 0
  handoff_dir="/root/voidlinux-guide-security-handoff"
  if (( DRY_RUN )); then
    printf '%b\n' "${YELLOW}[dry-run]${RESET} create root-only hardware-security handoff at $TARGET_ROOT$handoff_dir"
    [[ "$SECURE_BOOT_MODE" == prepare ]] && printf '%b\n' "${YELLOW}[dry-run]${RESET} chroot $TARGET_ROOT sbctl setup and sbctl status"
    return 0
  fi
  mkdir -p "$TARGET_ROOT$handoff_dir"; chmod 0700 "$TARGET_ROOT$handoff_dir"
  if [[ "$SECURE_BOOT_MODE" == prepare ]]; then
    chroot "$TARGET_ROOT" sbctl setup
    chroot "$TARGET_ROOT" sbctl status > "$TARGET_ROOT$handoff_dir/sbctl-status.txt" 2>&1 || true
    cat > "$TARGET_ROOT$handoff_dir/secure-boot-next-steps.md" <<'EOF'
# Secure Boot manual enrollment handoff

`sbctl setup` was run, but this installer did **not** create or enroll firmware keys and did not enable Secure Boot. Review the EFI files generated by your actual GRUB and kernel packages before proceeding.

1. Run `sbctl status` and confirm the firmware is in the expected setup state.
2. Run `sbctl create-keys` only after backing up existing firmware keys and documenting dual-boot requirements.
3. Locate EFI binaries under `/boot/efi`, register each intended binary with `sbctl sign -s <path>`, then run `sbctl verify`.
4. Run `sbctl enroll-keys` only after validating the firmware and recovery plan. Consider `--microsoft` only when the machine needs the Microsoft key set for an existing boot chain.
5. Reboot into firmware setup and enable Secure Boot only after `sbctl verify` reports the expected signatures.

Never reset platform keys from a generic installer. Keep a bootable recovery medium and the LUKS passphrases before changing firmware enrollment.
EOF
  fi
  if [[ "$TPM2_MODE" != off ]]; then
    cat > "$TARGET_ROOT$handoff_dir/tpm2-next-steps.md" <<EOF
# TPM2 manual enrollment handoff

A TPM2 readiness check was requested. Existing LUKS passphrases remain the required recovery method.

The installed system uses LUKS2 on:

- root: $ROOT_DATA_DEV
- home: $HOME_DATA_DEV

When using the optional Clevis route, review its current documentation and test recovery first. A manual example for the root device is:

\`clevis luks bind -d $ROOT_DATA_DEV tpm2 '{"pcr_bank":"sha256","pcr_ids":"7"}'\`

Do not execute this blindly. PCR 7 changes with Secure Boot policy and firmware key changes. Verify the active PCR strategy, regenerate/initramfs requirements and an interactive-passphrase fallback before binding a token. The installer deliberately does not remove any LUKS passphrase or automatically bind TPM2 state.
EOF
  fi
  if [[ "$FIDO2_MODE" == check ]]; then
    cat > "$TARGET_ROOT$handoff_dir/fido2-boundary.md" <<'EOF'
# FIDO2 compatibility boundary

FIDO2 readiness was checked only. Standard LUKS2 FIDO2 enrollment normally uses `systemd-cryptenroll` and a matching early-boot unlock implementation. Current Void package metadata does not expose this as a distinct supported installer path, so the installer does not create FIDO2 LUKS token metadata automatically.

Keep the LUKS passphrase as recovery access. Add a FIDO2 enrollment only after independently confirming that the target initramfs and unlock stack support the selected token's `hmac-secret` extension.
EOF
  fi
  chmod 0600 "$TARGET_ROOT$handoff_dir"/* 2>/dev/null || true
}

write_redacted_backup() {
  local backup_root now summary_file
  now="$(date -u +%Y%m%dT%H%M%SZ)"
  backup_root="/root/voidlinux-guide-install-backup-$now"
  BACKUP_DIR="$backup_root"
  if (( DRY_RUN )); then
    printf '%b\n' "${YELLOW}[dry-run]${RESET} create root-only redacted backup at $TARGET_ROOT$backup_root"
    return
  fi
  mkdir -p "$TARGET_ROOT$backup_root"; chmod 0700 "$TARGET_ROOT$backup_root"
  summary_file="$TARGET_ROOT$backup_root/install-summary.env"
  {
    printf '# Redacted VoidLinux-Guide installation summary. No passwords or LUKS passphrase.\n'
    printf 'INSTALLER_VERSION=%q\n' "$INSTALLER_VERSION"
    printf 'TARGET_ARCH=%q\nTARGET_LIBC=%q\nXBPS_TARGET=%q\nREPO_URL=%q\nTARGET_MIRROR_URL=%q\n' "$TARGET_ARCH" "$TARGET_LIBC" "$XBPS_TARGET" "$REPO_URL" "$TARGET_MIRROR_URL"
    printf 'TARGET_DISK=%q\nBOOT_MODE=%q\nPARTITION_LAYOUT=%q\nENCRYPTION=%q\n' "$TARGET_DISK" "$BOOT_MODE" "$PARTITION_LAYOUT" "$ENCRYPTION"
    printf 'ESP_DEV=%q\nBOOT_DEV=%q\nROOT_DATA_DEV=%q\nHOME_DATA_DEV=%q\nROOT_CRYPT_NAME=%q\nHOME_CRYPT_NAME=%q\n' "$ESP_DEV" "$BOOT_DEV" "$ROOT_DATA_DEV" "$HOME_DATA_DEV" "$ROOT_CRYPT_NAME" "$HOME_CRYPT_NAME"
    printf 'HOSTNAME_VALUE=%q\nTARGET_USER=%q\nDESKTOP=%q\nDISPLAY_PROTOCOL=%q\nGPU=%q\n' "$HOSTNAME_VALUE" "$TARGET_USER" "$DESKTOP" "$DISPLAY_PROTOCOL" "$GPU"
    printf 'TPM2_MODE=%q\nFIDO2_MODE=%q\nSECURE_BOOT_MODE=%q\n' "$TPM2_MODE" "$FIDO2_MODE" "$SECURE_BOOT_MODE"
    printf 'PACKAGES=%q\n' "$(package_list)"
  } > "$summary_file"
  chmod 0600 "$summary_file"
  cp -a "$TARGET_ROOT/etc/fstab" "$TARGET_ROOT$backup_root/fstab" 2>/dev/null || true
  cp -a "$TARGET_ROOT/etc/crypttab" "$TARGET_ROOT$backup_root/crypttab" 2>/dev/null || true
  cp -a "$TARGET_ROOT/etc/default/grub" "$TARGET_ROOT$backup_root/grub.default" 2>/dev/null || true
  cp -a "$TARGET_ROOT/etc/dracut.conf.d" "$TARGET_ROOT$backup_root/dracut.conf.d" 2>/dev/null || true
  cp -a "$TARGET_ROOT/etc/xbps.d" "$TARGET_ROOT$backup_root/xbps.d" 2>/dev/null || true
  cp -a "$TARGET_ROOT/root/voidlinux-guide-security-handoff" "$TARGET_ROOT$backup_root/security-handoff" 2>/dev/null || true
  find "$TARGET_ROOT/boot/efi" -type f -printf '%P\n' > "$TARGET_ROOT$backup_root/efi-files.txt" 2>/dev/null || true
  find "$TARGET_ROOT/var/service" -maxdepth 1 -type l -printf '%f -> %l\n' > "$TARGET_ROOT$backup_root/enabled-services.txt" 2>/dev/null || true
  chroot "$TARGET_ROOT" xbps-query -l > "$TARGET_ROOT$backup_root/packages.tsv" 2>/dev/null || true
  chroot "$TARGET_ROOT" xbps-query -L > "$TARGET_ROOT$backup_root/repositories.txt" 2>/dev/null || true
  if [[ "$SECURE_BOOT_MODE" == prepare ]]; then chroot "$TARGET_ROOT" sbctl status > "$TARGET_ROOT$backup_root/sbctl-status.txt" 2>&1 || true; fi
  {
    printf 'installer=%s\n' "$INSTALLER_VERSION"
    printf 'created_utc=%s\n' "$now"
    printf 'state_stages=%s\n' "$COMPLETED_STEPS"
    printf 'disk_report_before_install_is_not_stored_to_avoid_serial exposure\n'
    printf 'backup includes only redacted configuration; it excludes passwords, LUKS passphrases, private Secure Boot keys, token material and QR payloads.\n'
  } > "$TARGET_ROOT$backup_root/README.txt"
  (cd "$TARGET_ROOT$backup_root" && sha256sum ./* > SHA256SUMS) 2>/dev/null || true
  chmod 0600 "$TARGET_ROOT$backup_root"/* 2>/dev/null || true
}

write_recovery_report() {
  local recovery_root now
  now="$(date -u +%Y%m%dT%H%M%SZ)"
  recovery_root="/root/voidlinux-guide-recovery-$now"
  if (( DRY_RUN )); then
    printf '%b\n' "${YELLOW}[dry-run]${RESET} create non-destructive recovery report at $TARGET_ROOT$recovery_root"
    return 0
  fi
  mkdir -p "$TARGET_ROOT$recovery_root"; chmod 0700 "$TARGET_ROOT$recovery_root"
  {
    printf 'VoidLinux-Guide recovery report\n'
    printf 'created_utc=%s\n' "$now"
    printf 'installer=%s\n' "$INSTALLER_VERSION"
    printf 'target_disk=%s\nboot_mode=%s\nlayout=%s\nencryption=%s\n' "$TARGET_DISK" "$BOOT_MODE" "$PARTITION_LAYOUT" "$ENCRYPTION"
    printf 'state_stages=%s\n' "$COMPLETED_STEPS"
    printf 'This report was created without partitioning or package mutation.\n'
  } > "$TARGET_ROOT$recovery_root/README.txt"
  cp -a "$TARGET_ROOT/etc/fstab" "$TARGET_ROOT$recovery_root/fstab" 2>/dev/null || true
  cp -a "$TARGET_ROOT/etc/crypttab" "$TARGET_ROOT$recovery_root/crypttab" 2>/dev/null || true
  cp -a "$TARGET_ROOT/etc/default/grub" "$TARGET_ROOT$recovery_root/grub.default" 2>/dev/null || true
  chroot "$TARGET_ROOT" xbps-query -L > "$TARGET_ROOT$recovery_root/repositories.txt" 2>/dev/null || true
  chroot "$TARGET_ROOT" xbps-query -l > "$TARGET_ROOT$recovery_root/packages.tsv" 2>/dev/null || true
  cat > "$TARGET_ROOT$recovery_root/static-xbps-rescue.sh" <<'EOF'
#!/bin/sh
# Manual recovery handoff. Review every command before executing it.
# Boot an official Void live image, mount/chroot the target, then fetch static XBPS
# from the selected official mirror's /static/ directory. For a glibc target set
# XBPS_ARCH to the target architecture before using the static tools.
# Official reference: https://docs.voidlinux.org/xbps/troubleshooting/static.html
set -eu
printf '%s\n' 'No repair command is executed automatically by this file.'
printf '%s\n' 'Inspect fstab, crypttab, grub.default and packages.tsv first.'
EOF
  chmod 0700 "$TARGET_ROOT$recovery_root/static-xbps-rescue.sh"
  (cd "$TARGET_ROOT$recovery_root" && sha256sum ./* > SHA256SUMS) 2>/dev/null || true
  chmod 0600 "$TARGET_ROOT$recovery_root"/* 2>/dev/null || true
  log "Recovery report written to $recovery_root inside the mounted target"
}

show_passwords() {
  if (( DRY_RUN )); then
    log 'Dry-run: password placeholders are not displayed.'
    return 0
  fi
  show_secret root "$ROOT_PASSWORD"; show_secret "$TARGET_USER" "$USER_PASSWORD"
  unset ROOT_PASSWORD USER_PASSWORD CRYPT_PASSPHRASE
}

cleanup() {
  if (( DRY_RUN )); then return 0; fi
  sync || true
  [[ -z "$SWAP_DEV" ]] || swapoff "$SWAP_DEV" 2>/dev/null || true
  umount -R "$TARGET_ROOT" 2>/dev/null || true
  if [[ "$ENCRYPTION" == luks1-lvm ]]; then
    vgchange -an "$VG_NAME" 2>/dev/null || true
    cryptsetup close "$VG_NAME" 2>/dev/null || true
  elif [[ "$ENCRYPTION" == luks2-separate ]]; then
    cryptsetup close "$HOME_CRYPT_NAME" 2>/dev/null || true
    cryptsetup close "$ROOT_CRYPT_NAME" 2>/dev/null || true
  fi
}

main() {
  parse_args "$@"
  load_config
  load_state
  load_recovery_state
  check_host
  check_dependencies

  if (( RECOVERING )); then
    normalize_target
    normalize_desktop
    validate_inputs
    validate_target
    print_disk_report
    trap cleanup EXIT
    resume_open_and_mount
    write_recovery_report
    log 'Recovery report completed. No partitioning, package installation or automatic repair command was run.'
    return 0
  fi

  select_options
  normalize_target
  normalize_desktop
  validate_inputs
  validate_target
  network_preflight
  hardware_security_preflight
  state_file_default
  print_disk_report
  summary
  if (( DRY_RUN )); then log 'Dry-run selected: no disk, package, password, service or state-file changes will be made.'
  else
    confirm_existing_signatures
    confirm "The next step can erase the ENTIRE target disk $TARGET_DISK."
  fi
  trap cleanup EXIT
  if (( RESUMING )); then resume_open_and_mount; else save_state; fi
  run_stage partition partition_target
  mount_chroot_api
  run_stage bootstrap bootstrap_target
  run_stage configure configure_target
  run_stage packages install_target_packages
  run_stage accounts configure_accounts
  run_stage services configure_services
  run_stage bootloader install_bootloader
  run_stage hardware-security configure_hardware_security
  run_stage backup write_redacted_backup
  show_passwords
  if (( ! DRY_RUN )); then rm -f "$STATE_FILE"; fi
  log 'Installation completed. Review the root-only backup, record passwords, then reboot only when ready.'
}

main "$@"
