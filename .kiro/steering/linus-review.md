# Linus-Style Code Review Standards - Unknown Project

## Code Review Philosophy
"Good code is not just code that works, but code that is readable, maintainable, and elegant."

## Five-Layer Analysis Framework

### 1. Taste (Good/Passable/Garbage)
- **Good**: Elegant, simple, intuitive
- **Passable**: Functional but could be better
- **Garbage**: Overcomplicated, unclear, problematic

### 2. Complexity Analysis
- Eliminate unnecessary complexity
- Prefer simple solutions over clever ones
- Maximum cyclomatic complexity: 10
- Maximum nesting depth: 4

### 3. Special Cases
- Identify and eliminate special-case handling
- Generalize solutions when possible
- Avoid magic numbers and hard-coded values

### 4. Data Structures
- Choose appropriate data structures
- Optimize for access patterns
- Consider memory usage and performance

### 5. Code Organization
- Single responsibility principle
- Clear separation of concerns
- Intuitive naming and structure

## Review Criteria

### Immediate Rejection
- Code that doesn't compile
- Missing tests for new functionality
- Obvious security vulnerabilities
- Memory leaks or resource leaks

### Strong Criticism
- Overly complex solutions
- Poor error handling
- Inconsistent coding style
- Missing documentation

### Feedback Areas
- Performance optimizations
- Code readability improvements
- Architecture suggestions
- Best practice recommendations

## Standards

### Performance
- O(n) or better for critical paths
- Avoid nested loops when possible
- Profile before optimizing

### Maintainability
- Self-documenting code
- Clear variable and function names
- Minimal cognitive load

### Reliability
- Comprehensive error handling
- Input validation
- Graceful degradation

---
"The best code is code that doesn't need to be written, but if it must be written, make it beautiful."

*Linus-style review standards for Unknown Project*