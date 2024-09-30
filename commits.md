# Commit Convention for NixOS Configuration

This convention is inspired by the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.

## Types

The following types are used to categorize commits:

- `pkgs`: Changes to package definitions or versions
- `fix`: Bug fixes, including configuration-related fixes
- `feat`: New features or functionality, including new configuration options
- `docs`: Changes to documentation
- `refactor`: Changes that improve the internal structure or organization of the code/configuration
- `chore`: Maintenance tasks that keep the configuration or codebase healthy, including routine configuration updates

## Format

Commits should follow the format:

`[type]([module]): [brief description]`

- `[type]`: One of the above types
- `[module]`: The name of the module or service affected by the change (e.g. `networking`, `security`, `services.nginx`). If multiple modules are affected, list them separated by commas.
- `[brief description]`: A brief summary of the change written in the imperative mood.

## Examples

- `fix(networking): Fix DNS resolver configuration`
- `pkgs(nixpkgs): Upgrade to NixOS 21.05`
- `fix(security): Fix SSH key permissions`
- `feat(services.nginx): Add SSL support`
- `docs: Update README with new configuration instructions`
- `refactor(config): Simplify networking configuration`
- `chore(hosts/abc): xorg -> General DE config`
- `fix(pkgs): Correct version of package 'foo' to resolve compatibility issue`
- `refactor(security): Simplify firewall rules`
- `chore: Clean up outdated comments in configuration files`

## Notes

- `refactor` and `chore` are distinct types, with `refactor` implying a more significant change to the code/configuration, and `chore` implying a more routine or maintenance-oriented task.
- Renaming a file to better reflect its contents is an example of a `chore` commit.
- Use the imperative mood for the brief description: "Update DNS resolver" instead of "Updated DNS resolver."

## Related Issues

It is recommended to include references to related issues or tickets in the commit message, using the format `#123` for GitHub issues.

## Summary Checklist

- [ ] Use one of the defined types
- [ ] Specify the affected module
- [ ] Write a brief description in the imperative mood
- [ ] Reference related issues if applicable
