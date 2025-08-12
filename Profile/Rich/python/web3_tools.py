"""Web3 utilities"""
from typing import Optional
import json

def check_wallet_balance(address: str, network: str = "mainnet") -> dict:
    """Check wallet balance"""
    # Your Web3 logic here
    return {
        "address": address,
        "network": network,
        "balance": "1.337 ETH"
    }

def estimate_gas(from_addr: str, to_addr: str, value: str) -> int:
    """Estimate gas for transaction"""
    # Simplified example
    return 21000