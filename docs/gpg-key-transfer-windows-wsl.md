# Transferring GPG Keys from Windows to WSL

This guide covers exporting your GPG signing key from Windows and importing it into WSL Ubuntu for git commit signing.

## Prerequisites

- GPG installed on both Windows and WSL
- An existing GPG key on Windows
- WSL Ubuntu installed

## Step 1: List Your GPG Keys on Windows

Open PowerShell or Git Bash and list your secret keys:

```bash
gpg --list-secret-keys --keyid-format=long
```

Example output:

```
sec   rsa4096/5E9D7B9E55FA3B57 2024-02-25 [SC]
      C291CE1DAFF4EB72DCC170665E9D7B9E55FA3B57
uid                 [ultimate] Your Name <your.email@example.com>
ssb   rsa4096/75A7ED4BFFBA4EB5 2024-02-25 [E]
```

Note the key ID after `rsa4096/` (e.g., `5E9D7B9E55FA3B57`).

## Step 2: Export Your GPG Key

Export the secret key to a file:

```bash
gpg --export-secret-keys --armor YOUR_KEY_ID > $HOME/gpg-key-export.asc
```

Replace `YOUR_KEY_ID` with your actual key ID.

## Step 3: Import the Key into WSL

In WSL, import the key from the mounted Windows drive:

```bash
# Kill any existing GPG agent to avoid conflicts
gpgconf --kill gpg-agent

# Start a fresh agent
gpg-agent --daemon

# Import the key (use --batch to avoid TTY issues)
gpg --batch --import /mnt/c/Users/YOUR_USERNAME/gpg-key-export.asc
```

Verify the import:

```bash
gpg --list-secret-keys --keyid-format=long
```

## Step 4: Set Key Trust Level

The imported key will show as `[unknown]` trust. Set it to ultimate using the full fingerprint:

```bash
echo 'YOUR_FULL_FINGERPRINT:6:' | gpg --import-ownertrust
```

Example:

```bash
echo 'C291CE1DAFF4EB72DCC170665E9D7B9E55FA3B57:6:' | gpg --import-ownertrust
```

Verify the trust level changed to `[ultimate]`:

```bash
gpg --list-secret-keys --keyid-format=long
```

## Step 5: Configure Git to Use the Key

```bash
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
git config --global gpg.program gpg
```

## Step 6: Configure GPG_TTY

Ensure `GPG_TTY` is set in your shell configuration (`~/.zshrc` or `~/.bashrc`):

```bash
export GPG_TTY=$(tty)
```

This allows GPG to prompt for your passphrase in the terminal.

## Step 7: Clean Up

Delete the exported key file from Windows:

```powershell
Remove-Item $HOME\gpg-key-export.asc
```

Or from Git Bash/WSL:

```bash
rm /mnt/c/Users/YOUR_USERNAME/gpg-key-export.asc
```

## Troubleshooting

### "Inappropriate ioctl for device" Error

This occurs when GPG can't access the terminal for passphrase input. Solutions:

1. Kill and restart the GPG agent:
   ```bash
   gpgconf --kill gpg-agent
   gpg-agent --daemon
   ```

2. Use `--batch` flag for non-interactive import:
   ```bash
   gpg --batch --import /path/to/key.asc
   ```

3. Ensure `GPG_TTY` is exported in your shell config.

### "No such file or directory" Error

Ensure you're using the correct path format for WSL:
- Windows paths must be accessed via `/mnt/c/...`
- Example: `C:\Users\name\file.asc` becomes `/mnt/c/Users/name/file.asc`

### Key Shows as [unknown] Trust

You need to set the owner trust. Use the full 40-character fingerprint:

```bash
echo 'FULL_40_CHAR_FINGERPRINT:6:' | gpg --import-ownertrust
```

## Verification

Test that signing works:

```bash
echo "test" | gpg --clearsign
```

Test a git commit:

```bash
git commit --allow-empty -m "Test signed commit"
git log --show-signature -1
```
