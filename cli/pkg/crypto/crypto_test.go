package crypto

import (
	"bytes"
	"testing"
)

func TestEncryptDecrypt(t *testing.T) {
	passphrase := "super_secret_master_key_123"
	key := DeriveKey(passphrase)

	original := []byte("# My Private Diary\nThis note is zero-knowledge encrypted.")
	encryptedBase64, err := Encrypt(original, key)
	if err != nil {
		t.Fatalf("Encrypt error: %v", err)
	}

	decrypted, err := Decrypt(encryptedBase64, key)
	if err != nil {
		t.Fatalf("Decrypt error: %v", err)
	}

	if !bytes.Equal(original, decrypted) {
		t.Errorf("expected '%s', got '%s'", string(original), string(decrypted))
	}

	// Test with wrong key
	wrongKey := DeriveKey("wrong_passphrase")
	_, err = Decrypt(encryptedBase64, wrongKey)
	if err == nil {
		t.Errorf("expected decryption to fail with wrong key")
	}
}
