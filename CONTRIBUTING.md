# Contributing to the Project

## General Requirements
- Always create a **branch** from `dev` 
- Name your branch following the convention below.
- Write clear and objective commits.
- If possible, keep PRs small and focused.
- Merge your branch with dev

## Branch Naming

Use the structure:

```
Type/ObjectiveIdentifier/ClearDescription
```

Accepted types:
- **feature/usName/tk#** – New feature  
    _Example:_ `feature/userRegistration/tk102`

- **refactor/...** – Refactoring without changing functionality  
    _Example:_ `refactor/organizeServices`

- **fix/...** – Bug fix  
    _Example:_ `fix/invalidLogin`

- **chore/...** – Maintenance tasks (CI/CD, dependencies, etc.)  
    _Example:_ `chore/updateDependencies`

- **docs/...** – Documentation changes  
    _Example:_ `docs/installationGuide`

- **style/...** – Formatting, style, lint changes, etc.  
    _Example:_ `style/reformatFiles`

## Pull Requests

- Submit PRs to the `main` branch.
- Clearly describe what was done and attach screenshots.
- Link related issues if any.
- Wait for review and approval before merging.
- When merged, the task can be marked/considered "done"

## PR Template:

**Description**

Describe clearly and concisely what this pull request does.

**Relates to:**

**US# - User Story Name**

- TK# - Task Name
- TK# - Task Name

**Screenshots or Evidence**

Provide screenshots or evidence of the changes made, if applicable.
![Screenshot](https://placehold.co/150)

**Notes or Known Issues**

- Validation is only partially implemented (waiting on backend).
- Error handling still to be reviewed.