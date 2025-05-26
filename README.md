This repo provides a nocodb starting point, when you want to use it just as a local db viewer & editor 
Its running an nocodb instance locally with sqllite as the nocodb db.
It also runs a pgdb that is our business db, where we automate schema creation and seeding 
THen it has automation javascript that creates a nocodb source pointing to our business db and it connects it to a base 
so final result we get is a nocodb instance with pre defined base, schmea and data, so we can provide our repo manged schema and deploye it easyaly 

projstructure:
docker-compose running nocodb, base_pg, 


readme.md # best practice docs for this repo 
.gitignore # ignore what needed
docker-compose.yml (defines services for nocodb and base_pg, and auto_setup)
    - nocodb (passing env variables from )
    - base_pg (mounting /docker-entrypoint-initdb.d/ to init_db/)
    - auto_setup (automates the creation of nocodb source and base) 

.env (holds nocodb conf, pg conf, auto created base conf (source name, base name))
/init_db/
   - 01_schema.sql (schema to be created when pgdb starts)
   - 02_seed_data.sql (data to be inserted into pgdb after schema creation)
  
/auto_setup/
  - connect_pg_base.js (automates the creation of nocodb source and base, currently called setup_auto.js, should run only if base with name from .env does not exist, anyway should log what happend)
  - package.json
  - Dockerfile (runs the autosetup)


automating pgdb schema creation and seeding (via psql script or docker mounting for pg database sql scripts )
automating pg_base creation



check in on current state of project and theway its factored then complete and clareify the plan above and do the refactor until project
is matching the plan, then run and check logs to see evrything works 

then update this readme with the final state of the project and how to use it


"# nocodb-auto-setup" 
