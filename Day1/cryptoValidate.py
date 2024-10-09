# 实践非对称加密 RSA（编程语言不限）：

# 先生成一个公私钥对
# 用私钥对符合 POW 4个开头的哈希值的 “昵称 + nonce” 进行私钥签名
# 用公钥验证
# 提交程序你的 Github 链接

from Crypto.Hash import SHA256
from Crypto.Signature import pkcs1_15
from Crypto.PublicKey import RSA
import hashlib

# Generate a new RSA key pair
key = RSA.generate(1024)

# Export the private and public keys
private_key = key.export_key()
public_key = key.publickey().export_key()

# Load the keys back as RSA objects
private_key_obj = RSA.import_key(private_key)
public_key_obj = RSA.import_key(public_key)

# Hash message
hash_msg = b"0000d9cb96dca762c996fc0c29b8a6f6e2f2078d112659ff7a4fed5c8b172430"

# Create the digest of the message
digest = SHA256.new(hash_msg)

# Sign the digest using the private key
signer = pkcs1_15.new(private_key_obj)
signature = signer.sign(digest)

# Verify the signature using the public key
verifier = pkcs1_15.new(public_key_obj)
try:
    verifier.verify(digest, signature)
    print("The signature is valid.")
except (ValueError, TypeError):
    print("The signature is invalid.")

