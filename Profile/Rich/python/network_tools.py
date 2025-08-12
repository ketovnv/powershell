"""Network utilities for PowerShell"""
import socket
import subprocess
from typing import List, Dict, Optional
from rich.console import Console
from rich.table import Table

console = Console()


def scan_ports(host: str, start_port: int = 1, end_port: int = 1000) -> List[int]:
    """Scan ports on target host"""
    open_ports = []

    for port in range(start_port, end_port + 1):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(0.1)
        result = sock.connect_ex((host, port))
        if result == 0:
            open_ports.append(port)
        sock.close()

    return open_ports


def ping_sweep(network: str) -> Dict[str, bool]:
    """Ping sweep network range"""
    results = {}
    base = ".".join(network.split(".")[:-1])

    for i in range(1, 255):
        ip = f"{base}.{i}"
        response = subprocess.run(
            ["ping", "-n", "1", "-w", "100", ip],
            capture_output=True,
            text=True
        )
        results[ip] = response.returncode == 0

    return results


def show_network_info():
    """Display network information in a nice table"""
    table = Table(title="Network Configuration")
    table.add_column("Interface", style="cyan")
    table.add_column("IP Address", style="green")

    # Add your network info logic here
    table.add_row("eth0", "192.168.1.100")

    console.print(table)
    return "Network info displayed"