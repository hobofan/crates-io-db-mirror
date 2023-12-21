CREATE DATABASE IF NOT EXISTS crates_io_computed;

CREATE OR REPLACE VIEW crates_io_computed.latest_versions AS
    SELECT DISTINCT ON (crate_id) versions.crate_id, id as latest_version_id FROM crates_io.versions ORDER BY semver_no_prerelease DESC, num DESC;

CREATE OR REPLACE VIEW crates_io_computed.latest_version_dependencies AS
    SELECT DISTINCT ON (crates.id, dependency_crates.id)
        crates.id AS `crate_id`,
        dependency_crates.id AS `dependency_crate_id`
    FROM crates_io.crates
    INNER JOIN crates_io_computed.latest_versions ON latest_versions.crate_id = crates.id
    INNER JOIN crates_io.dependencies ON latest_versions.latest_version_id = dependencies.version_id
    INNER JOIN crates_io.crates AS `dependency_crates` ON dependencies.crate_id = `dependency_crates`.id;


