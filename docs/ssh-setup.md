# SSH key management with the socket-activated OpenSSH agent

A minimal, portable SSH client setup: keys unlocked once per login by OpenSSH's
own `ssh-agent`, started on demand by systemd socket activation, with no
keyring, no shell-rc agent juggling, and no `ssh-add` run by hand.

---

## Requirements

### Required

| Requirement | Why | How to check |
|---|---|---|
| **systemd**, with the user manager running | Provides the socket activation and the `environment.d` mechanism this setup is built on | `systemctl --user is-system-running` |
| **`ssh-agent` with socket activation support** | Lets systemd own the listening socket and start the agent on first use | `man ssh-agent \| grep -c 'socket activation'` → non-zero |
| **An `ssh-agent.socket` user unit** | The socket systemd listens on | `systemctl --user cat ssh-agent.socket` |
| **A systemd-managed login session** | So `SSH_AUTH_SOCK` reaches GUI apps, not just shells | `systemctl --user is-active graphical-session.target` |

Socket activation landed in OpenSSH 10.0 (April 2025, portable build).
Upstream ships no systemd units, but most distributions now include
`ssh-agent.socket` / `ssh-agent.service` in their `openssh` client package — so
on current systemd distributions all four checks usually pass out of the box.
Run the checks rather than trusting a version number.

If the unit is genuinely missing, it is two short files. The essentials:
`ssh-agent.socket` needs `ListenStream=%t/ssh-agent.socket` and
`WantedBy=sockets.target`; `ssh-agent.service` needs `ExecStart=/usr/bin/ssh-agent -D`
(no `-a` flag — that is what selects socket-activation mode) and
`Requires=ssh-agent.socket`.

### Not required

This setup is **not** specific to any distribution, desktop, or display server.
None of the following matter: the distro (Arch, Fedora, Debian, …), the desktop
environment, the window manager or compositor, Wayland vs. X11, or the shell.

Only one step touches anything session-specific, and it is the optional
shell-rc fallback in step 3.

### Conflicts

Only one thing may own `SSH_AUTH_SOCK`. Disable any of these that are active
before starting, or they will race and you will get confusing "agent has no
identities" errors:

- `gcr-ssh-agent.socket` — the GNOME keyring agent, shipped by `gcr` (a
  `gnome-keyring` dependency), so present on many non-GNOME desktops
- `gpg-agent` with `enable-ssh-support` in `~/.gnupg/gpg-agent.conf`
- KDE's `ksshaskpass` / KWallet SSH integration
- `keychain`, or an `eval $(ssh-agent)` line in a shell rc file

Check what is currently enabled:

```bash
systemctl --user list-unit-files | grep -E 'ssh|gpg|keyring'
grep -r enable-ssh-support ~/.gnupg/ 2>/dev/null
echo "${SSH_AUTH_SOCK:-<unset>}"
```

### A note on desktop keyrings

The most common alternative to this setup is a keyring-backed agent
(`gcr-ssh-agent` with GNOME Keyring), whose selling point is remembering your
key passphrase so you never retype it.

Before choosing that, check whether your keyring is actually encrypted. Some
distributions and desktop images ship a **passwordless default keyring** so
that applications never prompt — in which case secrets are stored in cleartext:

```bash
# If your stored secrets are readable as plain text here, the keyring is unencrypted.
grep -a 'secret=' ~/.local/share/keyrings/*.keyring 2>/dev/null | head
```

Storing a key passphrase in an unencrypted keyring writes it in the clear next
to the key it protects, which is equivalent to having no passphrase at all. On
such systems, prefer the plain OpenSSH agent below: the passphrase lives only
in agent memory and is never written to disk.

---

## Setup

### 1. Generate keys

One key per **trust domain** (personal, work, a specific client), not one per
service. Fewer keys to enroll and rotate, and losing a laptop revokes cleanly.

```bash
mkdir -p ~/.ssh/config.d && chmod 700 ~/.ssh ~/.ssh/config.d

ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519_personal \
  -C "$(whoami)@$(hostnamectl --static) personal $(date +%Y-%m)"
```

- `ed25519` — small, fast, and the modern default. Use `rsa -b 4096` only for
  legacy servers that reject it.
- `-a 100` raises the KDF rounds used to derive the key-file encryption key
  from your passphrase, slowing offline brute force if the file leaks. **It has
  no effect on a key with no passphrase.**
- A dated comment makes it obvious what to revoke later.

See [Decision: passphrases](#decision-passphrases) before choosing one.

### 2. Enable the agent

```bash
systemctl --user enable --now ssh-agent.socket
```

Socket activation means no agent process runs until something first connects to
the socket, and systemd owns the socket path so it is stable across reboots.

### 3. Publish `SSH_AUTH_SOCK` to the session

```bash
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/ssh-agent.conf <<'EOF'
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket
EOF
```

`environment.d` is read by the systemd user manager, so every process it
launches — including a systemd-managed graphical session and every terminal and
GUI app inside it — inherits the variable.

No re-login is needed. The user manager re-runs its environment generators on
reload, so this applies the new file immediately:

```bash
systemctl --user daemon-reload
systemctl --user show-environment | grep SSH_AUTH_SOCK   # confirm
```

Prefer this over `systemctl --user set-environment`, which sets the value by
hand and can silently drift from what the file says.

One caveat, which no reload can avoid: a process inherits its environment at
`exec`, so **programs already running keep the old one**. Anything started after
the reload is fine — including, on sessions that launch applications as systemd
user units, apps started from the existing desktop session. Restart any
long-running program that still cannot see the agent; logging out and back in
resets everything. A reboot is never required.

**Optional fallback.** Shells that do not descend from the systemd user manager
(a bare TTY login, or a compositor started directly from `~/.bash_profile`
rather than by systemd) will not see the variable. If you use those, append to
your shell rc:

```bash
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.socket}"
```

The `:-` keeps it deferential: it only fills in a value if nothing else set one.

### 4. Client configuration

`~/.ssh/config`:

```sshconfig
# Per-host settings live in ~/.ssh/config.d/*.conf
# This include must stay ABOVE the "Host *" block below: ssh uses the FIRST
# value it obtains for each option, so host-specific settings only win if they
# are read before the global defaults.
Include ~/.ssh/config.d/*.conf

Host *
  AddKeysToAgent yes
  IdentitiesOnly yes
  ForwardAgent no
  HashKnownHosts yes
  ServerAliveInterval 60
```

`~/.ssh/config.d/github.conf`:

```sshconfig
Host github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
```

Then:

```bash
chmod 600 ~/.ssh/config ~/.ssh/config.d/*.conf
```

Why each global option:

- **`AddKeysToAgent yes`** — the key is added to the agent on first use, so
  `ssh-add` is never needed by hand. With a passphrase, the first connection of
  each login prompts once and caches for the session.
- **`IdentitiesOnly yes`** — offer only the key named for this host. Without it,
  ssh offers every key in the agent to every server, leaking your public key
  fingerprints to any host you connect to. The cost is that **every `Host` block
  must name its own `IdentityFile`**, and a wrong path fails as
  `Permission denied (publickey)` with no fallback.
- **`ForwardAgent no`** — agent forwarding lets root on the remote host use your
  keys for the life of the connection. Use `ProxyJump` to reach a host behind a
  bastion instead. Override per-host only where genuinely needed.
- **`HashKnownHosts yes`** — stores host names in `known_hosts` hashed, so the
  file does not become an inventory of your infrastructure if read.

### 5. Enroll and verify

Add the **public** key (`~/.ssh/id_ed25519_personal.pub`) to the service, then:

```bash
ssh -G github.com | grep -E '^(identityfile|identitiesonly|addkeystoagent) '
ssh -T git@github.com
ssh-add -l
```

`ssh -G` resolves the effective config without connecting — the fastest way to
confirm the `Include` ordering and `IdentityFile` path are right.

---

## Decision: passphrases

`AddKeysToAgent` prompts only if the key has a passphrase. With no passphrase
there is no prompt, ever — the key is stored unencrypted on disk.

**Full-disk encryption is not a substitute.** FDE covers the machine powered
off: theft, a pulled drive, a decommissioned disk. It does nothing while the
system is running and unlocked. A key passphrase additionally covers:

- **Code you run that reads your home directory** — a malicious or compromised
  package from any language ecosystem can read `~/.ssh/id_*` as an ordinary file
  and exfiltrate it. This is the realistic risk on a development machine.
- **Copies that leave the encrypted volume** — cloud backup of `$HOME`, an
  rsync to a NAS, a stray archive, a screen share.

**What a passphrase does not do:** stop malware in your live session. Once
`AddKeysToAgent` has loaded the key, anything running as your user can ask the
agent to sign and never needs the file. A passphrase protects the key *at rest*,
not the running session — a narrower guarantee than usually advertised. To
narrow that window, `AddKeysToAgent` also accepts a lifetime (`AddKeysToAgent 8h`
drops the key from the agent after eight hours) or `confirm`, which asks before
every use via the askpass helper from
[GUI passphrase prompts](#gui-passphrase-prompts).

Recommended: use a passphrase, and store it in a password manager rather than a
keyring. It costs one prompt per boot.

**A passphrase can be added or changed later without regenerating the key.** The
public key is unchanged, so nothing needs re-enrolling anywhere:

```bash
ssh-keygen -p -a 100 -f ~/.ssh/id_ed25519_personal
```

---

## Decision: backups

Do not back up or sync private keys between machines. Generate a fresh key per
device and enroll each one — then a lost laptop is a revocation, not a
compromise.

What does need preserving is your ability to get back in: keep each provider's
recovery codes, and enroll a second key wherever the service allows it.

---

## Optional extensions

None of these are needed for the setup above to work. Each is worth adding
under the conditions described.

### Git commit signing

Git commit authorship is unauthenticated metadata: anyone with push access can
set `user.email` to yours and commit, and the history will show your name on
code you never wrote. Signing makes authorship verifiable, and an SSH key can do
it without involving GPG.

**Worth it for** public repositories, where the "Verified" badge is how readers
distinguish your commits from spoofed ones; shared organisation repositories,
especially where branch protection requires signed commits; and limiting what an
attacker can forge with a stolen CI token or a compromised collaborator account.

**Skippable for** solo work in private repositories — there is no forgery to
detect and nobody checking signatures.

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_personal.pub
git config --global commit.gpgsign true
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers

# Needed for `git log --show-signature` to verify locally, not just to sign.
echo "<your-email> namespaces=\"git\" $(cat ~/.ssh/id_ed25519_personal.pub)" \
  > ~/.ssh/allowed_signers
```

Forges generally keep authentication keys and signing keys in separate lists, so
the same public key must be uploaded twice — once as each — before commits show
as verified.

Trade-off: `commit.gpgsign true` makes **every commit fail** when the key is
unavailable. Set it per-repository rather than globally if that is disruptive.

### Hardware-backed keys

A FIDO2 security key is the significant upgrade over everything above. It closes
the exfiltration gap that a passphrase only narrows: the private key cannot be
copied off the device, so code reading your home directory has nothing to steal.

```bash
ssh-keygen -t ed25519-sk -O resident -O verify-required -f ~/.ssh/id_ed25519_sk
```

`-O resident` stores the key on the token so it can be recovered onto a new
machine with `ssh-keygen -K`; `-O verify-required` demands a PIN per use in
addition to the default touch, which also defeats malware abusing an
already-unlocked agent. Requires
OpenSSH 8.2+ on both ends. Enroll a second token or keep provider recovery codes
— a lost token is otherwise a lockout.

### GUI passphrase prompts

Only needed if a GUI application has to prompt for a passphrase with no terminal
attached. Point `SSH_ASKPASS` at an askpass helper and set
`SSH_ASKPASS_REQUIRE=prefer`; several exist (`ssh-askpass`, and Qt/GTK variants
shipped by desktop packages). An askpass helper only displays a dialog — it does
not store the passphrase, so it is safe alongside an unencrypted keyring.

---

## Troubleshooting

**`Could not open a connection to your authentication agent`**
`SSH_AUTH_SOCK` is unset in that shell. Expected in non-interactive contexts
that do not source your shell rc, and in terminals opened before the step 3
reload. Check with `echo "${SSH_AUTH_SOCK:-<unset>}"`.

**`Permission denied (publickey)`**
With `IdentitiesOnly yes`, the `IdentityFile` path must be exact and the file
must exist. Confirm what ssh resolves with `ssh -G <host> | grep identityfile`,
then trace the attempt with `ssh -v <host>`.

**Host-specific settings being ignored**
`Include` is below the `Host *` block. First value wins in ssh config, so the
include must come first.

**The agent keeps forgetting keys, or a different agent answers**
Something else is setting `SSH_AUTH_SOCK`. Re-check the [Conflicts](#conflicts)
section — `gcr-ssh-agent.socket` is the usual culprit, and it is enabled by
default on more systems than expected.
