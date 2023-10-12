<div align="center">

  <h1 style="border-bottom: none">
      <b>Currency Converter</b>
  </h1>
  
  <p>
    This demo project shows my coding style 😎 <br /><br />
    The project contains a currency converter that receives exchange rates from a remote server.<br /> The application also caches requests to the server
  </p>
</div>
<div align="center">

![swift](https://img.shields.io/badge/SWIFT-ff3d29)
![coverage](https://img.shields.io/badge/COVERAGE-72%25-green)
![clean architecture](https://img.shields.io/badge/SOLID-f0207a)
![clean architecture](https://img.shields.io/badge/CLEAN%20ARCHITECTURE-657cee)

</div>

## Features

. Main features of this project:

- Unit tests (coverage 72%)
- SOLID principles
- Clean Architecture Principles
- All dependencies initialized in the composition root, so it is easy to replace any component
- SwiftLint

## Architecture

The architecture of this app is based on the "Clean Architecture" principle, which ensures that each component of the app is independent and easily testable. The app consists of four main parts:

- **Domain**: This is where the core business logic of the app is implemented. It contains entities, use cases, and repositories that define the app's functionality and behavior.

- **Data**: This component deals with the app's data sources and storage. The data layer interacts with the domain layer through services, ensuring that the business logic remains decoupled from the data layer.

- **Presentation**: This component is responsible for displaying data to the user and handling user interactions. In this app, the presentation layer uses the Model-View-ViewModel (MVVM) architecture pattern, along with Combine for binding. The presentation layer is built with UIKit, but it can be easily replaced with SwiftUI.

- **Application**: The application layer contains the flow models that define the logic between screens. This ensures that the presentation layer remains agnostic to the navigation and routing of the app.

Overall, the clean architecture of this app ensures that each component is well-defined and testable, leading to a more maintainable and scalable codebase.

## License

MIT
