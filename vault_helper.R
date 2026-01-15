library(httr)
library(jsonlite)

# Function to authenticate with Vault and get token
get_vault_token <- function(vault_url, role_id, secret_id) {
  
  auth_endpoint <- paste0(vault_url, "/v1/auth/approle/login")
  message(paste("Authenticating with Vault at:", auth_endpoint))
  
  response <- POST(
    auth_endpoint,
    body = list(
      role_id = role_id,
      secret_id = secret_id
    ),
    encode = "json",
    timeout(30)
  )
  
  if (status_code(response) != 200) {
    stop(paste("Vault authentication failed. Status:", status_code(response),
               "Response:", content(response, "text")))
  }
  
  token_data <- content(response, "parsed")
  message("✓ Successfully authenticated with Vault")
  
  return(token_data$auth$client_token)
}

# Function to retrieve secret from Vault (KV v1)
get_vault_secret <- function(vault_url, token, secret_path) {
  
  # KV v1 API path
  secret_endpoint <- paste0(vault_url, "/v1/", secret_path)
  message(paste("Retrieving secret from:", secret_endpoint))
  
  response <- GET(
    secret_endpoint,
    add_headers(`X-Vault-Token` = token),
    timeout(30)
  )
  
  if (status_code(response) != 200) {
    stop(paste("Failed to retrieve secret. Status:", status_code(response),
               "Response:", content(response, "text")))
  }
  
  secret_data <- content(response, "parsed")
  
  # Debug output
  message("=== Vault Secret Structure ===")
  message(paste("Response keys:", paste(names(secret_data), collapse = ", ")))
  
  # KV v1: Data is in secret_data$data
  if (is.null(secret_data$data)) {
    stop("No 'data' field found in Vault response")
  }
  
  message(paste("Data field keys:", paste(names(secret_data$data), collapse = ", ")))
  message("✓ Retrieved secret using KV v1 format")
  
  return(secret_data$data)
}

# Function to get GCP service account credentials
get_gcp_credentials <- function(vault_url, role_id, secret_id, secret_path) {
  message("=== Starting GCP Credentials Retrieval ===")
  
  # Authenticate with Vault
  vault_token <- get_vault_token(vault_url, role_id, secret_id)
  
  # Retrieve secret
  secret <- get_vault_secret(vault_url, vault_token, secret_path)
  
  message("\n=== Processing Secret ===")
  message(paste("Secret has", length(names(secret)), "keys:", paste(names(secret), collapse = ", ")))
  
  # Find the base64-encoded service account JSON
  # Common key names
  possible_keys <- c(
    "data",                    # Sometimes it's nested under 'data'
    "service_account",
    "service_account_json",
    "gcp_service_account",
    "gcp_credentials",
    "credentials",
    "json",
    "key",
    "value"
  )
  
  base64_string <- NULL
  found_key <- NULL
  
  # Search for base64 string in known keys
  for (key in possible_keys) {
    if (key %in% names(secret)) {
      value <- secret[[key]]
      
      # Check if it's a character string longer than 100 chars (likely base64)
      if (is.character(value) && nchar(value) > 100) {
        message(paste("✓ Found base64 string in key:", key))
        message(paste("  Length:", nchar(value), "characters"))
        base64_string <- value
        found_key <- key
        break
      }
      
      # If it's a list with nested data, recurse one level
      if (is.list(value)) {
        message(paste("Checking nested list in key:", key))
        for (nested_key in names(value)) {
          nested_value <- value[[nested_key]]
          if (is.character(nested_value) && nchar(nested_value) > 100) {
            message(paste("✓ Found base64 string in nested key:", key, "->", nested_key))
            message(paste("  Length:", nchar(nested_value), "characters"))
            base64_string <- nested_value
            found_key <- paste(key, nested_key, sep = "$")
            break
          }
        }
        if (!is.null(base64_string)) break
      }
    }
  }
  
  # If still not found, try any long string
  if (is.null(base64_string)) {
    message("Searching all keys for long strings...")
    for (key in names(secret)) {
      value <- secret[[key]]
      if (is.character(value) && nchar(value) > 100) {
        message(paste("✓ Found base64 string in key:", key))
        message(paste("  Length:", nchar(value), "characters"))
        base64_string <- value
        found_key <- key
        break
      }
    }
  }
  
  if (is.null(base64_string)) {
    stop(paste("Could not find base64-encoded service account JSON.",
               "\nAvailable keys:", paste(names(secret), collapse = ", "),
               "\nPlease check your Vault secret structure."))
  }
  
  message(paste("\n=== Decoding Base64 from key:", found_key, "==="))
  
  # Decode base64
  tryCatch({
    # Remove whitespace
    base64_string <- gsub("\\s+", "", base64_string)
    
    # Decode
    decoded_raw <- base64_dec(base64_string)
    json_string <- rawToChar(decoded_raw)
    
    message(paste("✓ Decoded to", nchar(json_string), "characters"))
    
    # Show first 100 chars for debugging
    message(paste("First 100 chars:", substr(json_string, 1, 100), "..."))
    
  }, error = function(e) {
    stop(paste("Failed to decode base64:", e$message))
  })
  
  # Parse JSON
  message("\n=== Parsing Service Account JSON ===")
  tryCatch({
    service_account <- fromJSON(json_string, simplifyVector = FALSE)
    message("✓ JSON parsed successfully")
    message(paste("  Keys:", paste(names(service_account), collapse = ", ")))
  }, error = function(e) {
    stop(paste("Failed to parse JSON:", e$message,
               "\nFirst 200 chars of decoded string:", substr(json_string, 1, 200)))
  })
  
  # Validate required fields
  required_fields <- c("type", "project_id", "private_key", "client_email")
  missing_fields <- setdiff(required_fields, names(service_account))
  
  if (length(missing_fields) > 0) {
    stop(paste("Service account JSON is missing required fields:",
               paste(missing_fields, collapse = ", ")))
  }
  
  message("✓ Service account validated")
  message(paste("  Type:", service_account$type))
  message(paste("  Project ID:", service_account$project_id))
  message(paste("  Client Email:", service_account$client_email))
  
  # Write to temp file
  message("\n=== Writing Credentials File ===")
  temp_cred_file <- tempfile(fileext = ".json")
  
  tryCatch({
    write(toJSON(service_account, auto_unbox = TRUE, pretty = TRUE), temp_cred_file)
    
    # Verify
    test_read <- fromJSON(temp_cred_file)
    file_size <- file.info(temp_cred_file)$size
    
    message(paste("✓ Written to:", temp_cred_file))
    message(paste("✓ File size:", file_size, "bytes"))
    
    return(temp_cred_file)
    
  }, error = function(e) {
    stop(paste("Failed to write credentials file:", e$message))
  })
}