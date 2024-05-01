import secrets

def generate_secret_key():
    # Generate a 32-byte (256-bit) URL-safe secret key
    return secrets.token_urlsafe(32)

key = generate_secret_key()
print(key)
