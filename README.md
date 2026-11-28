# AIOps



# How to navigate this code:

# LOCAL RUN:
		SET APPLICATION ENV
		#=======================
		conda create -n flaskenv
		conda env install pip
		pip install flask psycopg2-binary



		SET APPLICATION DB
		#=======================
		sudo docker pull postgres
		docker run -i -p 5432:5432 --name mypostgres -e POSTGRES_PASSWORD=postgres -d postgres
		docker exec -it mypostgres bin/bash
		psql postgres postgres
		create a db called flask_db (postgres=# CREATE DATABASE flask_db;)

		If needed:
		CREATING A NEW USER
		postgres# CREATE USER cesar WITH PASSWORD '12345';
		postgres# GRANT ALL PRIVILEGES ON DATABASE flask_db TO cesar;

		OTHER COMMANDS
		postgres# \l               # list db 
		postgres# \c flask_db      # switch to flask_db
		postgres# \d               # check available tables
		postgres# select * from <tablename>
		postgres# \q               # quit

		export POSTGRES_DB="flask_db"
		export POSTGRES_USER="cesar"
		export POSTGRES_PASSWORD="12345"
		export POSTGRES_URL="localhost" or.....a given url


		\c flask_db
		CREATE TABLE books (
			id SERIAL PRIMARY KEY,
			title VARCHAR(100) NOT NULL,
			author VARCHAR(100) NOT NULL,
			pages_num INT NOT NULL,
			review TEXT
		);

		\d : list tables
		flask_db=# ALTER TABLE books OWNER TO cesar;


		RUN THE APPLICATION
		#=======================
		go to Flask-app/ : app-flask/
			python3 init_db.py : to initiate the  DB
			python3 app.py or python3 -m flask run : to run the application




# CLOUD RUN:
	- INFRASTRUCTURE: go to terraform/ : main.tf to understand services being created
	- APPLICATION   : go to Flask-app/ : app-flask/app.py : for app entrypoint
										app-flask/init_db.py: for db initialization
										Dockerfile: for dockerlizing(app image creation) the application 									 
										kube-app-postgreslk: for deploying the app to k8s from created images 
	- CICD PIPELINE : go to .github/workflow/pipeline.yml : to understand the pipeline stages,jobs, actions and tasks

	- ENVIRONMENT PACKAGES: go to pyproject.toml to understand what packages being installed (for local run or cloud)



	# Interacting with the deployed cluster
	1. Install Required CLI Tools (If Not Already Installed)
		• AWS CLI v2
		• kubectl: Used to inspect nodes, deploy containers, and check logs inside Kubernetes.
				(sudo snap install kubectl --classic)
	2. Configure Your test-user Credentials Locally
		aws configure
			• AWS Access Key ID: <your-test-user-access-key>
			• AWS Secret Access Key: <your-test-user-secret-key>
			• Default region name: us-east-2
			• Default output format: json
	3. Verify your terminal is authenticated as test-user:bash
			• aws sts get-caller-identity
	3. Connect kubectl to Your EKS Cluster
		aws eks update-kubeconfig --region us-east-2 --name test-aiops-use2-eks


	4. Run Your First kubectl Commands
		kubectl cluster-info
		kubectl get namespaces
		kubectl get nodes
		kubectl get pods -A

	5. Deploy and Manage Applications
		Once kubectl get nodes shows your EC2 nodes as Ready, you interact with the cluster by applying declarative YAML files:
		bash
	# Deploy an application (Deployment, Service, Secrets, etc.)
		kubectl apply -f deployment.yaml

	# Check running pods and public LoadBalancer URLs
		kubectl get pods
		kubectl get services

	# View live container logs or open a shell inside a pod
		kubectl logs <pod-name>
		kubectl exec -it <pod-name> -- /bin/sh

	# View you application
		kubectl get svc flask-app-service (glab the <EXTERNAL-IP> )
		Open http://<EXTERNAL-IP> in your browser.

#=======================================================================================K8S RUN
# Change: host='localhost'                 host='postgres-service'




# REFERENCE
# https://www.digitalocean.com/community/tutorials/how-to-use-a-postgresql-database-in-a-flask-application -->