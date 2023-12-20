default:
  just --list

run_clickhouse_server:
  mkdir -p server
  cd server && clickhouse server

fetch_and_update_to_latest:
  ./download_latest.sh
  ./upsert_latest.sh