library(httr)
library(jsonlite)
# Function to authenticate with Vault and get token
get_vault_token <- function(vault_url, role_id, secret_id) {
  auth_endpoint <- paste0(vault_url, "/v1/auth/approle/login")
  
  response <- POST(
    auth_endpoint,
    body = list(
      role_id = role_id,
      secret_id = secret_id
    ),
    encode = "json"
  )
  
  if (status_code(response) != 200) {
    stop("Failed to authenticate with Vault: ", content(response, "text"))
  }
  
  token_data <- content(response, "parsed")
  return(token_data$auth$client_token)
}
# Function to retrieve secret from Vault
get_vault_secret <- function(vault_url, token, secret_path) {
  secret_endpoint <- paste0(vault_url, "/v1/", secret_path)
  
  response <- GET(
    secret_endpoint,
    add_headers(`X-Vault-Token` = token)
  )
  
  if (status_code(response) != 200) {
    stop("Failed to retrieve secret from Vault: ", content(response, "text"))
  }
  
  secret_data <- content(response, "parsed")
  return(secret_data$data$data)  # Adjust based on your Vault KV version
}
# Function to get GCP service account credentials
get_gcp_credentials <- function(vault_url, role_id, secret_id, secret_path) {
  # Get Vault token
  vault_token <- get_vault_token(vault_url, role_id, secret_id)
  
  # Retrieve service account JSON
  secret <- get_vault_secret(vault_url, vault_token, secret_path)
  
  # Convert to JSON file temporarily
  temp_cred_file <- tempfile(fileext = ".json")
  write(toJSON(secret, auto_unbox = TRUE), temp_cred_file)
  
  return(temp_cred_file)
}
