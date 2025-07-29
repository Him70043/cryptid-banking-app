# CryptID - Secure Identity Verification System

A full-stack web application implementing secure identity verification with fraud detection capabilities for the Australian financial sector.

## Features

- **Cryptographic Security**: RSA-2048 digital signatures, AES-256 encryption, SHA-3 hashing
- **Fraud Detection**: ML-powered anomaly detection with real-time risk scoring
- **Multi-Factor Authentication**: TOTP + biometric simulation
- **OWASP Top 10 Protection**: Comprehensive security measures
- **Compliance**: GDPR, Australian Privacy Principles, APRA CPS 234

## Technology Stack

- **Frontend**: React 18+ with TypeScript, Material-UI
- **Backend**: Python Flask with SQLAlchemy
- **Database**: PostgreSQL with encryption
- **ML Engine**: scikit-learn
- **Deployment**: Docker & Docker Compose

## Quick Start

```bash
# Clone and setup
git clone <repository>
cd cryptid

# Start with Docker
docker-compose up -d

# Access application
open https://localhost:3000
```

## Project Structure

```
cryptid/
├── backend/          # Python Flask API
├── frontend/         # React TypeScript app
├── database/         # PostgreSQL setup
├── ml-engine/        # Fraud detection models
├── docker/           # Docker configurations
├── docs/             # Documentation
└── tests/            # Test suites
```

## Security Features

- End-to-end encryption (TLS 1.3)
- Zero-knowledge proof components
- Real-time threat detection
- Immutable audit logs
- RBAC with least privilege

## Development

See individual component READMEs for detailed setup instructions.

## License

MIT License - See LICENSE file for details.