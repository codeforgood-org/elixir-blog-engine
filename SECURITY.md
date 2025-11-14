# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability within BlogEngine, please send an email to the maintainers or report it through GitHub's Security Advisory feature.

### Reporting Process

1. **GitHub Security Advisory** (Preferred)
   - Go to the repository's Security tab
   - Click "Report a vulnerability"
   - Fill out the advisory form with details

2. **Email Report**
   - Send details to the project maintainers
   - Include the word "SECURITY" in the subject line
   - Provide as much information as possible

### What to Include

Please include the following information in your report:

- Type of vulnerability (e.g., SQL injection, XSS, command injection)
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it
- Your assessment of the severity

### What to Expect

- **Acknowledgment**: You should receive an acknowledgment within 48 hours
- **Communication**: We will keep you informed about the progress of fixing the vulnerability
- **Disclosure**: We will work with you to understand the issue and determine an appropriate disclosure timeline
- **Credit**: We will credit you for the discovery (unless you prefer to remain anonymous)

## Security Best Practices for Users

When using BlogEngine, follow these security best practices:

### Data Security

1. **Backup Regularly**
   ```bash
   > export ~/backups/blog-$(date +%Y%m%d).json
   ```

2. **Protect Your Data**
   - Keep `priv/data/posts.json` permissions restricted
   - Don't commit sensitive post content to public repositories
   - Use `.gitignore` to exclude data files from version control

3. **File Permissions**
   ```bash
   chmod 600 priv/data/posts.json  # Only owner can read/write
   ```

### Input Validation

BlogEngine sanitizes user input, but be aware:

- All user input is treated as text
- No code execution from post content
- JSON files are validated before import

### Export/Import Security

When using export/import features:

1. **Verify File Sources**
   - Only import files from trusted sources
   - Inspect JSON files before importing
   - Watch for unusually large files

2. **File Paths**
   - Use absolute paths for export/import
   - Avoid exporting to web-accessible directories
   - Don't import from untrusted network locations

### Dependency Security

Keep dependencies updated:

```bash
# Check for outdated dependencies
mix hex.outdated

# Update dependencies
mix deps.update --all

# Audit dependencies for known vulnerabilities
mix deps.audit
```

## Known Limitations

### Current Security Considerations

1. **Local Storage**
   - Posts stored in plain text JSON
   - No encryption at rest
   - Suitable for local, single-user scenarios

2. **Access Control**
   - No user authentication
   - No role-based access control
   - Designed for single-user CLI usage

3. **Network Security**
   - No network communication (CLI only)
   - No remote access vulnerabilities
   - No web server exposure

### Not Suitable For

BlogEngine is **not designed** for:

- Multi-user environments without proper OS-level access controls
- Storing sensitive or confidential information
- Production environments requiring encryption
- Scenarios requiring audit trails
- Network-accessible deployments without additional security layers

## Secure Deployment

If you want to use BlogEngine in a shared environment:

1. **Use OS-Level Security**
   ```bash
   # Create dedicated user
   sudo useradd -m blogengine

   # Restrict file access
   chown -R blogengine:blogengine /path/to/blog_engine
   chmod 700 /path/to/blog_engine
   ```

2. **Separate Environments**
   - Use different data directories for different users
   - Don't share the escript binary between users
   - Each user should have their own installation

3. **Container Isolation**
   - Use Docker for isolation (see Dockerfile)
   - Run with non-root user
   - Mount data directory as volume with restricted permissions

## Security Updates

We take security seriously and will:

- Release patches for confirmed vulnerabilities promptly
- Communicate security issues through GitHub Security Advisories
- Maintain a security changelog in CHANGELOG.md
- Credit researchers who responsibly disclose vulnerabilities

## Disclosure Policy

When we receive a security report, we will:

1. Confirm the vulnerability and determine its impact
2. Develop and test a fix
3. Release a patch update
4. Publish a security advisory
5. Credit the reporter (if desired)

We aim to resolve critical vulnerabilities within 7 days and moderate vulnerabilities within 30 days.

## Questions?

If you have questions about this security policy, please open a GitHub issue with the "question" label.

## Acknowledgments

We appreciate the security research community and recognize the following researchers:

- None reported yet

---

**Last Updated**: 2025-11-13
