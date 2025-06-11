use std::env::{self};
use std::fs::{self};

use super::ConfigError;

pub struct Config {
    pub postgres_database_name: String,
    pub postgres_hostname: String,
    pub postgres_password: String,
    pub postgres_username: String,
}

impl Config {
    pub fn load() -> Result<Self, ConfigError> {
        let postgres_database_name = get_env_var("ISKPRINTER_POSTGRES_DATABASE_NAME")?;

        let postgres_hostname = get_env_var("ISKPRINTER_POSTGRES_HOSTNAME")?;

        let postgres_username = get_env_var("ISKPRINTER_POSTGRES_USERNAME_PATH")
            .and_then(|path| fs::read_to_string(&path).map_err(ConfigError::FileReadError))
            .map(|content| content.trim_end().to_string())?;

        let postgres_password = get_env_var("ISKPRINTER_POSTGRES_PASSWORD_PATH")
            .and_then(|path| fs::read_to_string(&path).map_err(ConfigError::FileReadError))
            .map(|content| content.trim_end().to_string())?;

        Ok(Config {
            postgres_database_name,
            postgres_hostname,
            postgres_password,
            postgres_username,
        })
    }
}

fn get_env_var(var_name: &str) -> Result<String, ConfigError> {
    env::var(var_name).map_err(|_| ConfigError::EnvVarError(var_name.to_string()))
}
