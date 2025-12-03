# Core Coding Principles and Patterns

Follow SOLID, DRY, KISS, YAGNI, Separation of Concerns, and Modularity in all code.

## SOLID Principles
- **S**ingle Responsibility: One class, one reason to change
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable for base types
- **I**nterface Segregation: Small, focused interfaces
- **D**ependency Inversion: Depend on abstractions, not concretions

## DRY (Don't Repeat Yourself)
Extract common logic. Every knowledge piece has one authoritative representation.

## KISS (Keep It Simple, Stupid)
Simplicity over complexity. Avoid over-engineering.

## YAGNI (You Aren't Gonna Need It)
Implement only what's needed now. No speculative features.

## Separation of Concerns
Separate presentation, business logic, and data access layers.

## Modularity
High cohesion, low coupling. Encapsulate implementation details.

## Review Checklist
- [ ] Single Responsibility (SRP)
- [ ] Can extend without modifying (OCP)
- [ ] Dependencies use abstractions (DIP)
- [ ] No duplicated logic (DRY)
- [ ] Simple solution (KISS)
- [ ] Only needed features (YAGNI)
- [ ] Concerns separated (SoC)
- [ ] Modules cohesive & loosely coupled

Refer to full principles.md for detailed examples and language-specific guidance.
