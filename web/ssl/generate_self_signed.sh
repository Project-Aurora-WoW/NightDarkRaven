#!/bin/bash
# ============================================================================
# Ночь темного Ворона — Генерация самоподписанного SSL-сертификата
# Для разработки. В проде используйте Let's Encrypt или коммерческий сертификат.
# ============================================================================

set -e

CERT_DIR="certs"
CERT_NAME="nightdarkraven"

mkdir -p "$CERT_DIR"

echo "Generating private key..."
openssl genrsa -out "$CERT_DIR/$CERT_NAME.key" 2048

echo "Generating certificate signing request..."
openssl req -new -key "$CERT_DIR/$CERT_NAME.key" -out "$CERT_DIR/$CERT_NAME.csr" -subj "/C=RU/ST=Moscow/L=Moscow/O=NightDarkRaven/CN=localhost"

echo "Generating self-signed certificate (valid 365 days)..."
openssl x509 -req -days 365 -in "$CERT_DIR/$CERT_NAME.csr" -signkey "$CERT_DIR/$CERT_NAME.key" -out "$CERT_DIR/$CERT_NAME.crt"

echo ""
echo "Done! Certificates in $CERT_DIR/"
echo "  $CERT_NAME.key  — приватный ключ"
echo "  $CERT_NAME.crt  — сертификат (импортируйте в браузер как доверенный)"