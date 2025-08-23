# AWS CLI Integration

This stow package provides AWS CLI configuration and integration for your dotfiles setup.

## What's Included

### Configuration Files
- **`.aws/config`** - Main AWS CLI configuration with multiple profiles
- **`.aws/credentials`** - Credentials template (secure by default)
- **`README.md`** - This documentation file

### Features
- **Multi-profile support** (dev, staging, prod)
- **Secure credential management** using credential helpers
- **Architecture-aware installation** (x86_64 and ARM64 support)
- **Shell completions** for ZSH
- **Useful aliases** for common AWS operations
- **Session Manager plugin** installation script

## Installation

The AWS CLI is automatically installed when you run the main `install` script. The installation:

1. **Detects your system architecture** (x86_64 or ARM64)
2. **Downloads the appropriate installer** from AWS
3. **Installs AWS CLI v2** with proper verification
4. **Deploys configuration** via stow
5. **Sets up shell integration** (completions and aliases)

## Configuration

### Profiles
The configuration includes three default profiles:

- **`default`** - Your primary AWS account
- **`dev`** - Development environment
- **`staging`** - Staging environment  
- **`prod`** - Production environment

### Security Features
- **Credential helper integration** with aws-vault
- **MFA support** for all profiles
- **Role assumption** capabilities
- **Session timeouts** for security

## Usage

### Basic Commands
```bash
# List all profiles
awsp

# Show current configuration
awsl

# Get current region
awsr

# Get current account info
awssts

# List EC2 instances
awsinst

# List available regions
awsreg
```

### Profile Switching
```bash
# Use a specific profile
aws --profile dev s3 ls

# Set default profile
export AWS_PROFILE=dev

# Use a profile for a single command
aws --profile prod ec2 describe-instances
```

### Shell Completions
The AWS CLI provides comprehensive tab completion for:
- Commands and subcommands
- Resource names and IDs
- Region names
- Profile names
- Parameter values

## Optional Enhancements

### Session Manager Plugin
Install the AWS Session Manager plugin for secure EC2 access:

```bash
# Run the installation script
./lib/install_aws_session_manager.sh

# Or source and run the function
source ./lib/install_aws_session_manager.sh
install_aws_session_manager
```

### AWS SSO Integration
For organizations using AWS SSO, you can configure profiles like:

```ini
[profile sso-profile]
sso_start_url = https://your-sso-portal.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = YourSSORole
region = us-west-2
output = json
```

## Customization

### Adding New Profiles
Edit `.aws/config` to add custom profiles:

```ini
[profile custom]
region = eu-west-1
output = table
role_arn = arn:aws:iam::123456789012:role/MyRole
source_profile = default
mfa_serial = arn:aws:iam::123456789012:mfa/username
duration_seconds = 7200
```

### Modifying Aliases
Edit `.aliases` to customize AWS CLI aliases:

```bash
# Add your own aliases
alias myaws='aws --profile myprofile'
alias awslogs='aws logs describe-log-groups'
```

## Troubleshooting

### Common Issues

**Installation fails:**
- Check internet connectivity
- Verify you have sudo privileges
- Ensure unzip is installed: `sudo apt install unzip`

**Completions not working:**
- Restart your shell: `exec zsh`
- Check if AWS CLI is in PATH: `which aws`
- Verify bashcompinit is loaded in .zshrc

**Permission denied errors:**
- Check AWS credentials are properly configured
- Verify IAM permissions for the operation
- Use `aws sts get-caller-identity` to verify current identity

### Debug Mode
Enable AWS CLI debug output:

```bash
export AWS_CLI_DEBUG=1
aws s3 ls
```

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use IAM roles** instead of access keys when possible
3. **Enable MFA** for all AWS accounts
4. **Use temporary credentials** via AWS SSO or role assumption
5. **Regularly rotate** access keys
6. **Limit permissions** to minimum required access

## Support

For issues with this integration:
1. Check the main dotfiles documentation
2. Review AWS CLI documentation: https://docs.aws.amazon.com/cli/
3. Check AWS CLI GitHub: https://github.com/aws/aws-cli

## Version History

- **v1.0** - Initial implementation with basic AWS CLI v2 support
- **v1.1** - Added Session Manager plugin installation
- **v1.2** - Enhanced shell integration and aliases





