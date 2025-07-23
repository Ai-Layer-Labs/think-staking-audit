# THINK Token Staking System

A secure, flexible staking platform for tokens with time-locked commitments and comprehensive reward mechanisms.

![Token Staking & Reward System Architecture](docs/architecture.png)

## Getting Started

To get started, find the path that best describes you:

- **I'm a User...**
  - ➡️ **& want to learn how to stake:** [**Start with the User Guide &rarr;**](docs/user_docs.md)
- **I'm a Developer...**
  - ➡️ **& want to integrate with the system:** [**Read the Architecture Overview &rarr;**](docs/architecture_overview.md)
- **I'm a Security Auditor...**
  - ➡️ **& want to review the system's security:** [**Begin with the Audit Dossier &rarr;**](audit/README.md)

---

## System Overview

This staking platform is built with three core principles: security, data integrity, and developer-friendliness.

### Key Features

- **Security First**: Multi-layered security with role-based access control, including a dedicated `MULTISIG_ROLE` for critical recovery operations. It is protected from reentrancy attacks and can be paused in emergencies.
- **Advanced Data Management**: Uses a checkpoint system and binary search for highly-efficient historical balance queries (`O(log n)`), alongside individual stake tracking and daily statistical snapshots.
- **Developer Friendly**: A modular architecture separates logic (`StakingVault`) from data (`StakingStorage`), providing well-defined interfaces and gas-optimized operations to encourage ecosystem expansion.

## 🔗 Live Deployments & Status

### Ethereum Mainnnet

- **StakingVault**: [`0xdd60fd0d51234d22cb105e23867a056a05962e70`](https://etherscan.io/address/0xdd60fd0d51234d22cb105e23867a056a05962e70#code)
- **StakingStorage**: [`0xfaa8a501cf7ffd8080b0864f2c959e8cbcf83030`](https://etherscan.io/address/0xfaa8a501cf7ffd8080b0864f2c959e8cbcf83030#code)

### Sepolia Testnet

- **StakingVault**: [`0xE9b606be7c543B93D0FF5CE72A0E804d5f4147b2`](https://sepolia.etherscan.io/address/0xE9b606be7c543B93D0FF5CE72A0E804d5f4147b2/#code)
- **StakingStorage**: [`0xA71dF04aAC1DC6a0E62bC5a396ECaa976fF29f5A`](https://sepolia.etherscan.io/address/0xA71dF04aAC1DC6a0E62bC5a396ECaa976fF29f5A/#code)
- **PoolManager**: [`0x...`](https://sepolia.etherscan.io/address/0x...#code)
- **StrategiesRegistry**:[`0x034689a17fF618f6d166f1FEDaC2BD1893c84f96`](https://sepolia.etherscan.io/address/0x034689a17fF618f6d166f1FEDaC2BD1893c84f96#code)
- **RewardBookkeeper**:[`0x784cb3BAEC35e7E1Eba01FcDA93e95eD6C7615e7`](https://sepolia.etherscan.io/address/0x784cb3BAEC35e7E1Eba01FcDA93e95eD6C7615e7#code)
- **RewardManager**:[`0x176ce7ac49f636e2ca8762780ea1dc7c8917aebe`](https://sepolia.etherscan.io/address/0x176ce7ac49f636e2ca8762780ea1dc7c8917aebe#code)

### Project Status

The core staking and reward systems are feature-complete and ready for audit. The architecture supports both epoch-based (granted) and continuous (immediate) reward strategies.

## 📚 Full Documentation

For a detailed breakdown of all documentation, see the tables below.

### For Users

| Document                                       | Purpose                                              |
| ---------------------------------------------- | ---------------------------------------------------- |
| [User Guide](docs/user_docs.md)                | Basic staking concepts and step-by-step instructions |
| [Checkpoints Guide](docs/checkpoints_guide.md) | How your staking history is tracked for fair rewards |
| [Rewards Guide](docs/rewards_guide.md)         | Complete rewards system explanation                  |

### For Developers & Auditors

| Document                                                   | Purpose                                 |
| ---------------------------------------------------------- | --------------------------------------- |
| [Architecture Overview](docs/architecture_overview.md)     | System design and architecture overview |
| [Contract Specifications](docs/contract_specifications.md) | Detailed technical specifications       |
| [Audit Dossier](audit/README.md)                           | All security-related documentation      |

## 🛠️ Technology Stack

- **Smart Contracts**: Solidity ^0.8.30
- **Testing Framework**: Foundry
- **Security Libraries**: OpenZeppelin

---

# This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

---

**Need help?** Start with the [User Guide](docs/user_docs.md) or [Architecture Overview](docs/architecture_overview.md) depending on your needs.
