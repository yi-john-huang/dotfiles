# Commit Message Guidelines

Commit messages should follow a consistent format to improve readability and provide clear context about infrastructure changes.

## Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Type Prefixes

All commit messages must begin with one of these type prefixes:

- **feat**: New infrastructure features or enhancements
- **fix**: Bug fixes and issue resolution
- **docs**: Documentation changes (README, comments, etc.)
- **chore**: Maintenance tasks, dependency updates, provider upgrades
- **refactor**: Infrastructure changes that neither fix bugs nor add features
- **perf**: Performance improvements and optimizations
- **security**: Security-related changes and updates
- **config**: Configuration changes without functional impact

## Infrastructure-Specific Scopes

The scope provides context about which infrastructure component is affected:

- **cluster**: EKS cluster configuration changes
- **node**: Node group modifications (goplatform, billing, solution, gtc, etc.)
- **db**: Database changes (RDS, ElastiCache, DocumentDB)
- **net**: Networking changes (VPC, subnets, security groups)
- **alb**: Application Load Balancer configurations
- **nlb**: Network Load Balancer configurations
- **sg**: Security group rule changes
- **iam**: Identity and access management changes
- **k8s**: Kubernetes resource changes
- **dns**: Route53 and DNS record changes
- **cert**: ACM certificate management
- **lambda**: Lambda function changes
- **module**: Changes to reusable Terraform modules
- **config**: Environment-specific configuration changes

## Examples

```
feat(cluster): add EKS cluster version 1.31 support
fix(sg): correct CIDR blocks for partner access
feat(node): add gtc node group for telematics services
fix(db): resolve MySQL parameter group configuration
docs(k8s): update network policy documentation
chore(config): update terraform provider versions to latest
refactor(module): simplify EKS node group launch template
security(sg): restrict billing service access to required CIDRs
config(tw-prod): add new partner CIDR blocks for manufacturing
```

## Multi-Environment Considerations

When changes affect multiple environments, specify the scope:

```
feat(cluster/tw-prod): enable transit gateway connectivity
fix(db/eu-prod): correct DocumentDB instance configuration
config(all): update EKS cluster version across environments
```

## Operational Impact Indicators

Include operational impact in commit messages:

- **[breaking]**: Changes that require manual intervention
- **[migration]**: Database or state migrations required
- **[downtime]**: Changes that may cause service interruption
- **[security]**: Security-sensitive changes requiring review

Examples:
```
feat(cluster): upgrade EKS to 1.31 [migration]
fix(sg): emergency security group fix [security]
feat(alb): add WAF integration [breaking]
```

## Best Practices

1. **Subject Line**: Keep under 72 characters, use imperative mood
2. **Environment Context**: Specify environment when changes are environment-specific
3. **Partner Impact**: Note when changes affect partner integrations
4. **Service Impact**: Indicate which services are affected by the change
5. **Rollback Info**: Include rollback procedures for complex changes in body
6. **Issue References**: Link to tickets, issues, or change requests in footer

## Infrastructure-Specific Guidelines

- **Node Group Changes**: Always specify which node group is affected
- **Security Group Changes**: Include partner or service context
- **Database Changes**: Note if backup/restore procedures are needed
- **Network Changes**: Specify if connectivity testing is required
- **Certificate Changes**: Note domain validation requirements

These guidelines help maintain operational visibility and enable quick understanding of infrastructure changes across the complex multi-environment EKS setup.