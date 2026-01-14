library(httr)
library(jsonlite)

# Function to authenticate with Vault and get token
get_vault_token <- function(vault_url, role_id, secret_id) {
  
  # Try different auth paths (some Vault installations use different paths)
  auth_paths <- c(
    "/v1/auth/approle/login",
    "/auth/approle/login"
  )
  
  for (auth_path in auth_paths) {
    auth_endpoint <- paste0(vault_url, auth_path)
    message(paste("Attempting Vault authentication at:", auth_endpoint))
    
    tryCatch({
      response <- POST(
        auth_endpoint,
        body = list(
          role_id = role_id,
          secret_id = secret_id
        ),
        encode = "json",
        timeout(30)
      )
      
      message(paste("Response status:", status_code(response)))
      
      if (status_code(response) == 200) {
        token_data <- content(response, "parsed")
        message("Successfully authenticated with Vault")
        return(token_data$auth$client_token)
      } else {
        message(paste("Failed with status", status_code(response)))
        message(paste("Response:", content(response, "text")))
      }
      
    }, error = function(e) {
      message(paste("Error with path", auth_path, ":", e$message))
    })
  }
  
  stop("Failed to authenticate with Vault using all known auth paths: ", 
       content(response, "text", encoding = "UTF-8"))
}

# Function to retrieve secret from Vault
get_vault_secret <- function(vault_url, token, secret_path) {
  
  # Try different secret paths (KV v1 vs v2)
  secret_paths <- c(
    paste0("/v1/", secret_path),
    paste0("/", secret_path)
  )
  
  for (path in secret_paths) {
    secret_endpoint <- paste0(vault_url, path)
    message(paste("Attempting to retrieve secret from:", secret_endpoint))
    
    tryCatch({
      response <- GET(
        secret_endpoint,
        add_headers(`X-Vault-Token` = token),
        timeout(30)
      )
      
      message(paste("Response status:", status_code(response)))
      
      if (status_code(response) == 200) {
        secret_data <- content(response, "parsed")
        
        # Handle both KV v1 and v2 formats
        if (!is.null(secret_data$data$data)) {
          # KV v2 format
          message("Retrieved secret using KV v2 format")
          return(secret_data$data$data)
        } else if (!is.null(secret_data$data)) {
          # KV v1 format
          message("Retrieved secret using KV v1 format")
          return(secret_data$data)
        }
      } else {
        message(paste("Failed with status", status_code(response)))
        message(paste("Response:", content(response, "text")))
      }
      
    }, error = function(e) {
      message(paste("Error with path", path, ":", e$message))
    })
  }
  
  stop("Failed to retrieve secret from Vault: ", content(response, "text", encoding = "UTF-8"))
}

# Function to get GCP service account credentials
get_gcp_credentials <- function(vault_url, role_id, secret_id, secret_path) {
  message("Starting GCP credentials retrieval from Vault...")
  
  # Get Vault token
  vault_token <- get_vault_token(vault_url, role_id, secret_id)
  
  # Retrieve service account JSON
  secret <- get_vault_secret(vault_url, vault_token, secret_path)
  
  # Convert to JSON file temporarily
  temp_cred_file <- tempfile(fileext = ".json")
  write(toJSON(secret, auto_unbox = TRUE), temp_cred_file)
  
  message(paste("Credentials written to temp file:", temp_cred_file))
  
  return(temp_cred_file)
}