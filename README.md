\# Vitaliq: Integrated Medical Management System



Vitaliq is a professional, multi-tier academic project designed to enhance clinical service efficiency. Built with a modern tech stack, it leverages Edge-Cloud principles to ensure low-latency performance for critical medical data.



\## Project Architecture



The system is organized into a decoupled, containerized architecture:



\- \*\*`/frontend`\*\*: Flutter-based client application (Web \& Mobile support).

\- \*\*`/backend`\*\*: Django REST Framework API handling business logic and orchestration.

\- \*\*`/ai\_ml`\*\*: Python-based modules for predictive medical analytics and data preprocessing.

\- \*\*`/database`\*\*: PostgreSQL relational database schema and persistence layer.

\- \*\*`/docs`\*\*: Project documentation, including BRD, UI Mockups, and System Architecture diagrams.



---



\## Tech Stack



| Tier | Technology |

| :--- | :--- |

| \*\*Frontend\*\* | Flutter (Dart) |

| \*\*Backend\*\* | Django / Django REST Framework |

| \*\*Database\*\* | PostgreSQL |

| \*\*ML/AI\*\* | Python (Pandas, Scikit-learn) |

| \*\*DevOps\*\* | Docker \& Docker Compose |



---



\## Getting Started



\### Prerequisites

\- Docker Desktop (WSL 2 backend recommended for Windows 11)

\- Flutter SDK

\- Python 3.11+



\### Installation \& Setup



1\. \*\*Clone the repository:\*\*

&nbsp;  ```bash

&nbsp;  git clone \[https://github.com/your-username/vitaliq.git](https://github.com/your-username/vitaliq.git)

&nbsp;  cd vitaliq```



2\. \*\*Spin up the environment:\*\*

Use Docker Compose to launch the database and backend services:



```bash

docker-compose up --build

```



3\. Run the Frontend:

Navigate to the frontend directory and launch the Flutter web app:



```bash
cd frontend

flutter run -d chrome

```



\*\*Roadmap \& Documentation\*\*

Detailed project requirements and architecture diagrams can be found in the /docs directory. This project follows a professional SDLC (Software Development Life Cycle) to ensure academic and technical rigor.



