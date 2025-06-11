use sqlx::Connection;
use sqlx::postgres::{PgConnectOptions, PgConnection};
use std::process;
use tokio::{self};

use tracing::{error, info};
use tracing_subscriber::{filter::LevelFilter, fmt, prelude::*};

mod config;
use config::Config;

// Setup tracing with JSON output
fn setup_tracing() {
    tracing_subscriber::registry()
        .with(
            fmt::layer()
                .json()
                .with_current_span(true)
                .with_file(true) // Include file name
                .with_level(true) // Include the log level
                .with_line_number(true), // Include line number
        )
        .with(LevelFilter::INFO) // Set the minimum log level
        .init();
}

#[tokio::main]
async fn main() {
    setup_tracing();

    let config = Config::load().unwrap_or_else(|e| {
        error!("Failed to load configuration: {}", e);
        process::exit(1);
    });

    let conn_options = PgConnectOptions::new()
        .database(&config.postgres_database_name)
        .host(&config.postgres_hostname)
        .password(&config.postgres_password)
        .port(5432)
        .username(&config.postgres_username);

    match PgConnection::connect_with(&conn_options).await {
        Err(e) => {
            error!("Error connecting to postgres: {}", e);
            process::exit(1);
        }
        Ok(conn) => {
            info!("Connected to postgres");
        }
    }
}
