CREATE DATABASE IF NOT EXISTS crates_io;

SET allow_experimental_object_type = 1;

DROP TABLE IF EXISTS crates_io.badges;
DROP TABLE IF EXISTS crates_io.categories;
DROP TABLE IF EXISTS crates_io.crate_owners;
DROP TABLE IF EXISTS crates_io.crates;
DROP TABLE IF EXISTS crates_io.crates_categories;
DROP TABLE IF EXISTS crates_io.crates_keywords;
DROP TABLE IF EXISTS crates_io.dependencies;
DROP TABLE IF EXISTS crates_io.keywords;
DROP TABLE IF EXISTS crates_io.metadata;
DROP TABLE IF EXISTS crates_io.reserved_crate_names;
DROP TABLE IF EXISTS crates_io.teams;
DROP TABLE IF EXISTS crates_io.users;
DROP TABLE IF EXISTS crates_io.version_downloads;
DROP TABLE IF EXISTS crates_io.versions;

--
-- Name: badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.badges (
                               crate_id integer NOT NULL,
                               badge_type character varying NOT NULL,
                               attributes JSON NOT NULL
)
ENGINE = MergeTree()
PRIMARY KEY (crate_id, badge_type)
;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.categories (
                                   id integer NOT NULL,
                                   category character varying NOT NULL,
                                   slug character varying NOT NULL,
                                   description character varying DEFAULT ''::character varying NOT NULL,
                                   crates_cnt integer DEFAULT 0 NOT NULL,
                                   created_at DateTime64(6, 'UTC') DEFAULT now() NOT NULL,
                                   path character varying NOT NULL
)
ENGINE = MergeTree()
PRIMARY KEY (category)
;

--
-- Name: crate_owners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.crate_owners (
    crate_id integer NOT NULL,
    owner_id integer NOT NULL
        COMMENT 'This refers either to the `users.id` or `teams.id` column, depending on the value of the `owner_kind` column',
    created_at DateTime64(6, 'UTC') DEFAULT now() NOT NULL,
    created_by integer,
    owner_kind integer NOT NULL
        COMMENT '`owner_kind = 0` refers to `users`, `owner_kind = 1` refers to `teams`.',
)
ENGINE = MergeTree()
PRIMARY KEY (crate_id, owner_id, owner_kind)
;

--
-- Name: crates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.crates (
    id integer NOT NULL,
    name character varying NOT NULL,
    updated_at DateTime64(6, 'UTC') DEFAULT now() NOT NULL,
    created_at DateTime64(6, 'UTC') DEFAULT now() NOT NULL,
    downloads integer DEFAULT 0 NOT NULL,
    description character varying,
    homepage character varying DEFAULT NULL,
    documentation character varying DEFAULT NULL,
    readme character varying DEFAULT NULL,
-- NOTE: This column was removed, as it didn't appear in the import
-- textsearchable_index_col tsvector NOT NULL,
    repository character varying DEFAULT NULL,
    max_upload_size integer,
    max_features smallint
)
ENGINE = MergeTree()
PRIMARY KEY (id)
;

--
-- Name: crates_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.crates_categories (
                                          crate_id integer NOT NULL,
                                          category_id integer NOT NULL
)
ENGINE = MergeTree()
PRIMARY KEY (crate_id, category_id)
;


--
-- Name: crates_keywords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.crates_keywords (
                                        crate_id integer NOT NULL,
                                        keyword_id integer NOT NULL
)
ENGINE = MergeTree()
PRIMARY KEY (crate_id, keyword_id)
;


--
-- Name: dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.dependencies (
                                     id integer NOT NULL,
                                     version_id integer NOT NULL,
                                     crate_id integer NOT NULL,
                                     req character varying NOT NULL,
                                     optional boolean NOT NULL,
                                     default_features boolean NOT NULL,
    -- TODO: Correct datatype + import parsing
                                     features character varying NOT NULL,
                                     target character varying DEFAULT NULL,
                                     kind integer DEFAULT 0 NOT NULL,
                                     explicit_name character varying DEFAULT NULL
)
ENGINE = MergeTree()
PRIMARY KEY (id)
;

--
-- Name: keywords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.keywords (
                                 id integer NOT NULL,
                                 keyword text NOT NULL,
                                 crates_cnt integer DEFAULT 0 NOT NULL,
                                 created_at DateTime64(6, 'UTC') DEFAULT now() NOT NULL
)
ENGINE = MergeTree()
PRIMARY KEY (id)
;

--
-- Name: metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.metadata (
                                total_downloads bigint NOT NULL
)
ENGINE = MergeTree()
PRIMARY KEY (total_downloads)
;

--
-- Name: reserved_crate_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.reserved_crate_names (
    name text NOT NULL
)
ENGINE = MergeTree()
PRIMARY KEY (name)
;

--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.teams (
    id integer NOT NULL,
    login character varying NOT NULL
        COMMENT 'Example: `github:foo:bar` means the `bar` team of the `foo` GitHub organization.',
    github_id integer NOT NULL
        COMMENT 'Unique team ID on the GitHub API. When teams are recreated with the same name then they will still get a different ID, so this allows us to avoid potential name reuse attacks.',
    name character varying,
    avatar character varying,
    org_id integer
        COMMENT 'Unique organization ID on the GitHub API. When organizations are recreated with the same name then they will still get a different ID, so this allows us to avoid potential name reuse attacks.',
-- CONSTRAINT teams_login_lowercase_ck CHECK (((login)::text = lower((login)::text)))
)
ENGINE = MergeTree()
PRIMARY KEY (id)
;

--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.users (
    id integer NOT NULL,
    gh_login character varying NOT NULL,
    name character varying,
    gh_avatar character varying DEFAULT NULL,
    gh_id integer NOT NULL,
)
ENGINE = MergeTree()
PRIMARY KEY (id)
;

--
-- Name: version_downloads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.version_downloads (
                                          version_id integer NOT NULL,
                                          downloads integer DEFAULT 1 NOT NULL,
                                          date date DEFAULT now() NOT NULL,
)
ENGINE = MergeTree()
PRIMARY KEY (version_id, date)
;

--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crates_io.versions (
    id integer NOT NULL,
    crate_id integer NOT NULL,
    num character varying NOT NULL,
    updated_at DateTime64(6, 'UTC') DEFAULT now() NOT NULL,
    created_at DateTime64(6, 'UTC') DEFAULT now() NOT NULL,
    downloads integer DEFAULT 0 NOT NULL,
-- TODO
-- features jsonb DEFAULT '{}'::jsonb NOT NULL,
    yanked boolean DEFAULT false NOT NULL,
    license character varying,
    crate_size integer,
    published_by integer,
    checksum character(64) NOT NULL,
    links character varying DEFAULT NULL,
    rust_version character varying DEFAULT NULL,
-- TODO
-- semver_no_prerelease public.semver_triple GENERATED ALWAYS AS (public.to_semver_no_prerelease((num)::text)) STORED
)
ENGINE = MergeTree()
-- TODO
PRIMARY KEY (id)
;

INSERT INTO crates_io.badges FROM INFILE './data/badges.csv' FORMAT CSV;
INSERT INTO crates_io.categories FROM INFILE './data/categories.csv' FORMAT CSV;
INSERT INTO crates_io.crate_owners FROM INFILE './data/crate_owners.csv' FORMAT CSV;
INSERT INTO crates_io.crates FROM INFILE './data/crates.csv' FORMAT CSV;
INSERT INTO crates_io.crates_categories FROM INFILE './data/crates_categories.csv' FORMAT CSV;
INSERT INTO crates_io.crates_keywords FROM INFILE './data/crates_keywords.csv' FORMAT CSV;
INSERT INTO crates_io.dependencies FROM INFILE './data/dependencies.csv' FORMAT CSV;
INSERT INTO crates_io.keywords FROM INFILE './data/keywords.csv' FORMAT CSV;
INSERT INTO crates_io.metadata FROM INFILE './data/metadata.csv' FORMAT CSV;
INSERT INTO crates_io.reserved_crate_names FROM INFILE './data/reserved_crate_names.csv' FORMAT CSV;
INSERT INTO crates_io.teams FROM INFILE './data/teams.csv' FORMAT CSV;
INSERT INTO crates_io.users FROM INFILE './data/users.csv' FORMAT CSV;
INSERT INTO crates_io.version_downloads FROM INFILE './data/version_downloads.csv' FORMAT CSV;
INSERT INTO crates_io.versions FROM INFILE './data/versions.csv' FORMAT CSV;
