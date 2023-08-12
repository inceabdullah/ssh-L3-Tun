# ssh-L3-Tun

ssh-L3-Tun is a robust Linux tool for managing Layer 3 SSH tunnels. It supports dynamic IP addressing, virtual Ethernet pairs, network namespace isolation, routing, NAT, and the ability to change the default route. Configuration is saved in YAML format.

## Features

- **Layer 3 SSH Tunnels**: Create and manage secure SSH tunnels at the network layer.
- **Dynamic IP Addressing**: Automatically handle IP address assignments.
- **Network Namespace Isolation**: Isolate network configurations using Linux namespaces.
- **Routing and NAT**: Set up custom routing and NAT rules.
- **Default Route Management**: Change the default route as needed.
- **YAML Configuration**: Save and load configurations using YAML files.

## Scripts

### `ssh_tunnel_manager.sh --mode [mode]`

This script manages SSH tunnel connections, allowing you to set up default connections, change connections, and more. The `--mode` parameter specifies the operation mode, which can be one of the following:

- `default`: Set up the default connection.
- `change`: Change the existing connection.

Additional parameters can be passed to the underlying scripts.

Usage:

```bash
./ssh_tunnel_manager.sh --mode default
./ssh_tunnel_manager.sh --mode change [REMOTE_IP]
```

### `setup.sh [REMOTE IP]`

This script sets up the initial configuration, including creating network namespaces, virtual Ethernet pairs, and SSH tunnels. If a remote IP is provided, it will be used to establish the SSH tunnel.

Usage:

```bash
./setup.sh [REMOTE_IP]
```

### `setups.sh`

This script sets up the initial configuration without establishing an SSH tunnel. It's useful for preparing the environment without connecting to a remote host.

Usage:

```bash
./setups.sh
```

### `default_connection.sh`

This script reads the saved configuration and sets up the default connection based on the parameters in the YAML file. It's useful for re-establishing a previously configured connection.

Usage:

```bash
./default_connection.sh
```

### `change_connection.sh [REMOTE IP]`

This script changes the existing SSH tunnel connection to a new remote IP address. It takes care of updating the configuration, tearing down the old connection, and establishing the new one.

Usage:

```bash
./change_connection.sh [REMOTE_IP]
```

## Installation

Clone the repository and make the scripts executable:

```bash
git clone https://github.com/username/ssh-L3-Tun.git
cd ssh-L3-Tun
chmod +x *.sh
```

## Dependencies

- iproute2
- autossh
- nftables

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

