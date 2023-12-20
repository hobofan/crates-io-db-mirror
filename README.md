# Crates.io DB mirror with Clickhouse

This repository contains some tooling to mirror the crates.io database ([provided via a database dump](https://crates.io/data-access#database-dumps)) into a ClickHouse database.

## Usage

Just is used as a task runner (you can also take a look into the `justfile` to see the raw commands).

### Running a ClickHouse server locally

- Clickhouse is assumed to be installed.

```shell
just run_clickhouse_server
```

### Update to latest dump

The following command will download the latest database dump (if there have been changes since the last download), and upsert that snapshot into the locally running database.

As repeat downloads are reduced and the upsert is quite fast, this can be called quite regularly (~multiple times per hour) to reduce the lag of getting the latest snapshot into the database.

```
just fetch_and_update_to_latest
```

## Misc

The `schema.sql` file contains the script to create the tables and insert the data from CSV.
It deletes all of the tables and will re-create them from scratch.
It's a version of the `schema.sql` file contained in the DB dump that has been adapted to the ClickHouse SQL dialect by hand on a best-effort basis.

Some of the original columns are omitted if they are not present in the CSV dump files, and some columns are not yet included in the schema (see `TODO` comments in the file).

## License

Licensed under either of these:

- Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or
  https://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or
  https://opensource.org/licenses/MIT)