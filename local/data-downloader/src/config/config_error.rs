use std::{
    fmt::{self},
    io::{self},
};

#[derive(Debug)]
pub enum ConfigError {
    EnvVarError(String),
    FileReadError(io::Error),
}

impl fmt::Display for ConfigError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ConfigError::EnvVarError(var_name) => {
                write!(f, "The environment variable {} was not present.", *var_name)
            }
            ConfigError::FileReadError(e) => write!(f, "File read error: {}", e),
        }
    }
}
