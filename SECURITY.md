# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within this dotfiles repository, please report it responsibly.

### How to Report

1. **Do NOT open a public issue** for security vulnerabilities
2. Send a private email or use GitHub's private vulnerability reporting
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix/Disclosure**: Depends on severity

## Security Measures in This Repository

### Secrets Management

This dotfiles repository takes the following measures to protect sensitive information:

1. **No Hardcoded Secrets**
   - API keys, tokens, and passwords are NEVER committed
   - Use `.gitignore` to exclude sensitive files
   - Local configuration files (`.zshrc.local`, `.gitconfig.local`) are not tracked

2. **git-secrets Integration**
   - Pre-commit hooks scan for AWS credentials and common secret patterns
   - Prevents accidental commit of sensitive data

3. **SOPS/age Encryption** (Optional)
   - Sensitive configuration can be encrypted using SOPS with age
   - See `docs/security/sops-age-setup.md` for setup instructions

### Shell Security

1. **Safe Shell Practices**
   - Scripts use `set -euo pipefail` for strict error handling
   - Input validation on user-provided data
   - Secure file permissions (600 for SSH keys, 700 for .ssh directory)

2. **Dependency Verification**
   - Homebrew packages are from official taps
   - Third-party scripts are reviewed before inclusion

### SSH Configuration

- SSH keys are never included in the repository
- SSH config uses secure defaults
- ControlMaster connections with secure socket permissions

## Best Practices for Users

When using this dotfiles repository:

1. **Review Before Use**
   - Read through scripts before running them
   - Understand what each configuration does

2. **Protect Local Secrets**
   - Keep `.zshrc.local` and `.gitconfig.local` outside version control
   - Use environment variables or encrypted files for sensitive data

3. **Regular Updates**
   - Keep your system and tools updated
   - Review changes when pulling updates

4. **Verify Authenticity**
   - Clone from the official repository
   - Verify commit signatures if available

## Security Checklist

For contributors and users:

- [ ] No hardcoded credentials in any file
- [ ] Sensitive files are in `.gitignore`
- [ ] Scripts validate user input
- [ ] File permissions are appropriate
- [ ] Dependencies are from trusted sources
- [ ] git-secrets hooks are installed

## Contact

For security concerns, please contact the repository maintainer through GitHub's private messaging or security advisory feature.
