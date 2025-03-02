# Decentralized Email Verification System

A proof-of-ownership mechanism for email authentication using Stacks blockchain.

## Overview

This project implements a decentralized system for verifying email ownership without exposing the actual email addresses on-chain. Instead, it uses cryptographic hashes to represent email addresses while maintaining privacy.

## Architecture

The system consists of three main smart contracts:

1. **Email Verification Contract**: Handles the verification process and user interaction
2. **Email Registry Contract**: Stores verification data and maintains user records
3. **Utils Contract**: Provides utility functions for the system

## Verification Process

1. A user submits a hash of their email address to request verification
2. The system generates a unique verification code/challenge
3. The user completes an off-chain verification (e.g., clicking a link sent to their email)
4. Upon successful verification, the system records the proof on the blockchain

## Security Considerations

- Email addresses are never stored on-chain, only their hashes
- The verification process uses a challenge-response mechanism
- Contract access controls prevent unauthorized modifications
- Time-based expiration for verification requests

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Node.js and npm/yarn for testing

### Installation

1. Clone this repository
2. Set up the development environment:

```bash
clarinet integrate
```

3. Run tests:

```bash
clarinet test
```

## Development

### Project Structure

```
email-verification/
├── contracts/          # Smart contracts
├── tests/              # Test files
├── Clarinet.toml       # Project configuration
└── README.md           # Documentation
```

### Smart Contracts

- `email-verification.clar`: Main verification logic
- `email-registry.clar`: Data storage and management
- `utils.clar`: Utility functions

## Testing

The project includes comprehensive tests to ensure security and functionality:

- Unit tests for individual contract functions
- Integration tests for the entire verification flow
- Edge cases and potential attack vectors

## License

[MIT License](LICENSE)
