# SOLID Principles in SafeSeasons

We follow SOLID strictly. All new code must conform.

## S – Single Responsibility Principle (SRP)

**Rule:** One type, one reason to change.

- **KeyValueStoring** / **ImageStoring**: Persistence only. No business logic.
- **Repositories**: Data access only (fetch/save). No UI, no use-case logic.
- **Use cases**: Orchestrate one cohesive domain action. Depend on repo protocols only.
- **ViewModels**: Present data for one screen. Depend on use-case protocols only.
- **Views**: Layout and user input only. Depend on ViewModels (or narrow protocols) only.

**No god objects.** DataManager-style “do everything” types are not allowed.

---

## O – Open/Closed Principle (OCP)

**Rule:** Open for extension, closed for modification.

- New data source (e.g. network): add a new repository implementation conforming to the existing protocol. No changes to use cases or ViewModels.
- New persistence backend: add a new `KeyValueStoring` / `ImageStoring` implementation. Repositories depend on protocols, not concretions.

---

## L – Liskov Substitution Principle (LSP)

**Rule:** Implementations must be substitutable for their protocols.

- Any `StateRiskRepositoryProtocol` implementation can replace another without breaking callers.
- Same for all repository, use-case, and (where we use them) ViewModel protocols.

---

## I – Interface Segregation Principle (ISP)

**Rule:** Clients depend only on what they use.

- **Views** receive only their ViewModel (e.g. `HomeViewModel`), not a global “DataManager.”
- **ViewModels** depend only on the use-case protocol(s) they need.
- **Use cases** depend only on the repository protocol(s) they need.
- Prefer small, focused protocols over large “kitchen sink” interfaces.

---

## D – Dependency Inversion Principle (DIP)

**Rule:** Depend on abstractions, not concretions.

- **Use cases** depend on `*RepositoryProtocol`, not concrete repositories.
- **ViewModels** depend on `*UseCaseProtocol`, not concrete use cases.
- **Repositories** depend on `KeyValueStoring` / `ImageStoring`, not `UserDefaults` / `FileManager` directly.
- **Composition root** (DependencyContainer) is the only place that creates concrete types and wires them.

**Dependency flow:** Views → ViewModels → Use Cases → Repositories → Persistence. All arrows point to protocols/types defined in the same or lower layer, never to concrete implementations from a higher layer.
