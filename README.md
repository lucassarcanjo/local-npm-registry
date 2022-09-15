# 📦 Local NPM Registry

Private registry powered by [Verdaccio](https://verdaccio.org/) and works with docker-compose to act like a proxy between a project and npm registry. With this, you can work in an npm library and fastly publish to test in your application.

Contains:

- conf: configuration file and a user httppasswd
- storage: folder of published packages

## Usage

You need to have `docker` and `docker compose` installed on your machine. Then, run:

```bash
$> cd ./verdaccio

$> docker-compose up
```

Verdaccio will be available on `http://localhost:4873/`. This repo also contains a script to optimize the workflow of publishing a package and refresh de dependency on your app. Use at your own risk!

# License

This project is under the Apache 2.0 license. See [here](#license) for details.
