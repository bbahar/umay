# umay #
An interactive platform for monitoring blood transfusions

Instructions:
1. Install docker (https://www.docker.com)
2. Clone the repository (git clone https://github.com/bbahar/umay.git)
3. Run the docker compose file (docker compose -f "docker-compose.yaml" up -d --build)
4. Go http://localhost:8787 for Rstudio and run simulate.R and then load.R scripts which simulates data and loads into the postgresql database
5. Go http://localhost:3000/?orgId=1 for Grafana and open 'RBC after Hb test' as the example dashboard
6. Stop and remove the containers (docker compose -f "docker-compose.yaml" down) when done
