<!-- filepath: c:\\Users\\user\\Desktop\\personalWorkspace\\notImportent\\nocode1\\README.md -->
# NocoDB Local Development Environment

This repository provides a Dockerized NocoDB starting point for local database viewing and editing. It sets up a NocoDB instance that uses SQLite for its own metadata and connects to a separate PostgreSQL database which serves as the primary business database. The PostgreSQL database schema and initial data are automatically created and seeded.

Furthermore, an automation script (`auto_setup`) is included to:
1.  Wait for NocoDB and PostgreSQL services to be ready.
2.  Create a new data source in NocoDB pointing to the PostgreSQL business database.
3.  Create a new base within NocoDB linked to this new data source.

The final result is a NocoDB instance with a pre-defined base, schema, and data, allowing for easy management and deployment of your repository-managed schema.

## Project Structure

```
.
├── .env                  # Holds NocoDB config, PostgreSQL config, and auto-created base config
├── .env.example          # Example environment file
├── .gitignore            # Specifies intentionally untracked files
├── auto_setup/
│   ├── Dockerfile        # Dockerfile for the auto_setup service
│   ├── package.json      # Node.js dependencies for the automation script
│   └── setup_auto.js     # Script to automate NocoDB source and base creation
├── docker-compose.yml    # Defines services for NocoDB, PostgreSQL (base_pg), and auto_setup
├── init_db/
│   ├── 01_schema.sql     # SQL script to create the business database schema
│   └── 02_seed_data.sql  # SQL script to seed the business database with initial data
└── README.md             # This file: project overview and usage instructions
```

## Environment Variables

The project uses an `.env` file to manage configuration settings. Copy `.env.example` to `.env` and customize it. Key variables include:

*   **NocoDB Configuration:**
    *   `NC_PUBLIC_URL`: Public URL for NocoDB (e.g., "http://localhost:8080").
    *   `NC_PORT`: Port NocoDB listens on (e.g., 8080).
    *   `NC_AUTH_JWT_SECRET`: JWT secret for NocoDB authentication.
    *   `NC_ADMIN_EMAIL`: Admin email for NocoDB.
    *   `NC_ADMIN_PASSWORD`: Admin password for NocoDB.
*   **PostgreSQL (`base1_pg_db`) Configuration:**
    *   `BASE1_PG_DB`: Name of the PostgreSQL database (e.g., `base1_db`).
    *   `BASE1_PG_USER`: PostgreSQL username (e.g., `root`).
    *   `BASE1_PG_PASSWORD`: PostgreSQL password (e.g., `password`).
    *   `BASE1_PG_HOST_PORT`: Host port mapped to PostgreSQL's port 5432 (e.g., `5432`).
    *   `BASE1_PG_HOST`: (Optional, defaults to service name `base1_pg_db` in Docker) Hostname for PostgreSQL.
*   **Auto-Setup Configuration (for `auto_setup` service):**
    *   `BASE_TITLE`: Title for the base created in NocoDB (e.g., `Base1`).
    *   `SOURCE_TITLE`: Title for the data source created in NocoDB (e.g., `Base1 PG Source`).

## Services

The `docker-compose.yml` file defines the following services:

*   **`nocodb`**:
    *   Runs the latest NocoDB image.
    *   Configured using environment variables from the `.env` file.
    *   Persists NocoDB data in a Docker volume (`nocodb_data`).
    *   Depends on `postgres_db` and `auto_setup`.
*   **`postgres_db`**:
    *   Runs a PostgreSQL 15 image (or your preferred version).
    *   Serves as the business database.
    *   Environment variables for user, password, and database name are sourced from `.env`.
    *   Mounts the `/init_db/` directory to `/docker-entrypoint-initdb.d/`. This allows PostgreSQL to automatically execute the SQL scripts within `init_db/` upon startup, creating the schema and seeding data.
    *   Persists PostgreSQL data in a Docker volume (`postgres_data`).
*   **`auto_setup`**:
    *   Builds a Docker image from `./auto_setup/Dockerfile`.
    *   Runs the `setup_auto.js` script.
    *   Environment variables are passed from `.env` to configure its connection to NocoDB and PostgreSQL.
    *   Depends on `nocodb` and `postgres_db` to ensure these services are available before it attempts to configure NocoDB.
    *   Restarts on failure.

## Prerequisites

*   Docker
*   Docker Compose

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2.  **Create an environment file:**
    Copy the example environment file and customize it with your desired settings:
    ```bash
    copy .env.example .env
    ```
    **Important:**
    *   Review and update the passwords and secrets in `.env`, especially `NC_AUTH_JWT_SECRET` and `NC_ADMIN_PASSWORD`.
    *   Ensure `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB` in `.env` match the credentials NocoDB will use to connect to the `postgres_db` service. The `auto_setup` service also uses these to connect to PostgreSQL.

3.  **Build and run the services:**
    ```bash
    docker-compose up --build -d
    ```
    This command will:
    *   Build the `auto_setup` image if it doesn't exist or if its Dockerfile has changed.
    *   Pull the `nocodb` and `postgres` images if they are not already present locally.
    *   Start all defined services in detached mode (`-d`).

4.  **Access NocoDB:**
    Once the services are up and running (which might take a few moments, especially on the first run as images are downloaded and databases are initialized), you can access NocoDB in your web browser.
    *   The default URL is `http://localhost:8080` (or the port you specified in `NocoDB_HOST_PORT` in your `.env` file).
    *   Log in with the admin credentials specified in your `.env` file (`NC_ADMIN_EMAIL` and `NC_ADMIN_PASSWORD`).

5.  **Verify Setup:**
    *   You should see a new base created (default name: "My Automated Base" or as configured by `BASE_TITLE` in `.env`).
    *   This base should be connected to a data source named "ProductionDB" (or as configured by `SOURCE_TITLE` in `.env`), which points to your `postgres_db` container.
    *   The tables defined in `init_db/01_schema.sql` and populated by `init_db/02_seed_data.sql` should be visible and accessible within this base.

## How it Works

1.  **PostgreSQL Initialization:** When the `postgres_db` service starts, it automatically executes any `.sh`, `.sql`, or `.sql.gz` files found in the `/docker-entrypoint-initdb.d` directory. In this setup, `01_schema.sql` creates the database tables, and `02_seed_data.sql` populates them.
2.  **NocoDB Startup:** The `nocodb` service starts, initially without knowledge of the `postgres_db` as a data source for a user base.
3.  **Automated Configuration (`auto_setup`):**
    *   The `auto_setup` service waits for both `nocodb` and `postgres_db` to be operational.
    *   It then runs the `setup_auto.js` script. This script uses the NocoDB API to:
        *   Log in to NocoDB using the admin credentials.
        *   Check if a base with the configured name already exists. If not, it proceeds.
        *   Create a new data source connection to the `postgres_db` service (using connection details from the environment variables).
        *   Create a new base in NocoDB and link it to the newly created PostgreSQL data source.
    *   The script logs its actions, indicating whether the base and source were created or if they already existed.

## Customization

*   **Database Schema & Data:** Modify the SQL files in the `init_db/` directory to change the schema or initial data of your business database.
*   **NocoDB Configuration:** Adjust NocoDB settings (admin user, JWT secret, etc.) in the `.env` file.
*   **Base and Source Names:** Change the `BASE_TITLE` and `SOURCE_TITLE` in the `.env` file to customize the names used by the `auto_setup` script.
*   **Automation Logic:** Modify `auto_setup/setup_auto.js` if you need to change how NocoDB is configured (e.g., create multiple bases, different source types, etc.).
*   **PostgreSQL Version:** Change the image tag for the `postgres_db` service in `docker-compose.yml` (e.g., `postgres:14`).

## Troubleshooting

*   **Check Service Logs:** If something isn't working as expected, the first step is to check the logs for each service:
    ```bash
    docker-compose logs -f nocodb
    docker-compose logs -f postgres_db
    docker-compose logs -f auto_setup
    ```
*   **Ensure Ports are Free:** Make sure the ports defined in `.env` (e.g., `NocoDB_HOST_PORT`, `POSTGRES_HOST_PORT`) are not already in use on your host machine.
*   **Volume Permissions:** On some systems (especially Linux), you might encounter permission issues with Docker volumes. Ensure Docker has the necessary permissions to write to the volume locations.
*   **`.env` file:** Double-check that your `.env` file is correctly formatted and that all necessary variables are set, especially passwords and secrets.
*   **`auto_setup` script errors:** If the `auto_setup` script fails, its logs should provide details. Common issues could be incorrect NocoDB/PostgreSQL connection details or NocoDB API changes (though the script aims for robustness).

## Stopping the Environment

To stop all services:
```bash
docker-compose down
```
To stop and remove volumes (deleting all NocoDB and PostgreSQL data):
```bash
docker-compose down -v
```

## Future Enhancements (from original README)

*   The original README mentioned that the `connect_pg_base.js` (now `setup_auto.js`) should only run if a base with the name from `.env` does not exist. This logic is now implemented in the `setup_auto.js` script.





