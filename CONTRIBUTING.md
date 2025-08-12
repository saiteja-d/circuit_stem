
# Contributing to Circuit STEM

First off, thank you for considering contributing to Circuit STEM! We welcome any help, from reporting bugs to submitting new features.

## Code of Conduct

This project and everyone participating in it is governed by the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code. Please report unacceptable behavior.

## How Can I Contribute?

### Reporting Bugs

- **Ensure the bug was not already reported** by searching on GitHub under [Issues](https://github.com/your-username/circuit_stem/issues).
- If you're unable to find an open issue addressing the problem, [open a new one](https://github.com/your-username/circuit_stem/issues/new). Be sure to include a **title and clear description**, as much relevant information as possible, and a **code sample or an executable test case** demonstrating the expected behavior that is not occurring.

### Suggesting Enhancements

- Open a new issue with the `enhancement` label.
- Clearly describe the enhancement, why it would be useful, and provide examples if possible.

### Pull Request Process

1.  **Fork the repo** and create your branch from `main`.
2.  **Branch Naming:** Use a descriptive name, e.g., `feature/new-component-type` or `fix/level-loading-bug`.
3.  **Add code and tests.** Ensure your new code is covered by tests.
4.  **Update documentation** if you are changing any user-facing or architectural functionality.
5.  **Format and analyze your code.** Ensure your code adheres to the project's style by running:
    ```sh
    flutter format .
    flutter analyze
    ```
6.  **Ensure all tests pass:**
    ```sh
    flutter test
    ```
7.  **Issue that pull request!** Provide a clear description of the changes.

## Styleguides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature").
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...").
- Limit the first line to 72 characters or less.
- Reference issues and pull requests liberally after the first line.

### Dart Styleguide

- We adhere to the official [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.
- We use the linting rules defined in `analysis_options.yaml`.
