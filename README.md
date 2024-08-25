# FreelanceD

FreelanceD is a decentralized freelance marketplace built using Flutter and Solidity. It allows clients to post projects and freelancers to apply for them, with all transactions and interactions managed via smart contracts on the Ethereum blockchain.

## Features

- **Project Creation**: Clients can create projects with specific details such as title, description, budget, and deadline.
- **Freelancer Applications**: Freelancers can apply for projects and provide their proposals.
- **Milestone Management**: Projects can be divided into milestones, and freelancers can submit milestones for approval.
- **Dispute Resolution**: Disputes can be raised and resolved through the platform.
- **User Reputation**: Both clients and freelancers have reputations based on their interactions and feedback.

## Project Structure

```
.freelanced/
├── .dart_tool/
├── .idea/
├── android/
├── build/
├── lib/
├── macos/
├── smart_contract/
│ ├── contracts/
│ │ ├── artifacts/
│ │ │ └── FreelanceMarketplace_metadata.json
│ └── README.txt
├── pubspec.lock
├── pubspec.yaml
└── README.md
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Metamask (for interacting with the Ethereum blockchain)

### Installation

1. **Clone the repository**:

    ```sh
    git clone https://github.com/AmanSikarwar/freelanced.git
    cd freelanced
    ```

2. **Install Flutter dependencies**:

    ```sh
    flutter pub get
    ```

### Running the Application

1. **Compile and deploy smart contracts**:
    - Use Remix IDE or Hardhat to compile and deploy the smart contracts located in [`smart_contract/contracts/`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Famansikarwar%2FDevelopment%2FProjects%2FFlutter%2Ffreelanced%2Fsmart_contract%2Fcontracts%2F%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/Users/amansikarwar/Development/Projects/Flutter/freelanced/smart_contract/contracts/").

2. **Run the Flutter application**:

    ```sh
    flutter run
    ```

## Usage

- **Creating a Project**: Navigate to the "Create Project" section, fill in the project details, and submit.
- **Applying for a Project**: Browse available projects, select one, and submit your application.
- **Managing Milestones**: Clients can approve or reject submitted milestones.
- **Raising Disputes**: If there is a conflict, either party can raise a dispute for resolution.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License.

## Contact

For any inquiries, please contact [amansik.1910@gmail.com](mailto:amansik.1910@gmail.com).
