# Verdaccio Private Registry

Private registry that works with docker-compose to act like a proxy between a project and npm registry.

Contains:

- conf: configuration file and a user httppasswd
- storage: local of published packages

## Use

To run on `http://localhost:4873/` port:

```bash
$> docker-compose up
```