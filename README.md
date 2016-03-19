# FhirBridge

FhirBridge is an open source fhir server written in Jruby/Rails with Fhirbase backend Postgres database. It acts as
an API server for serving up FHIR (Fast Healthcare Interoperability Resources) resources. Most of the fhir specification
logic is implemented in the fhirbase database. A fhir client can be setup to interact
with the server and retrieve patient or medication resources using HTTP calls to the RESTful api. Supported calls include GET, CREATE, DELETE and PUT amongst others.

Demo:
www.fhirbridge.net

## Installation
For installation and setup we will use heroku cloud services. Heroku allows you to host small hobby apps for free if you
just want to experiment. Other hosting options (AWS) should work too if you know how to do such things. 
The installation is two part: setting up the API server and then setting up the DB:
### API server
- Clone the repository to a folder on your desktop (you could also download the zip instead). Open a terminal or cmd prompt and cd to the folder you want to clone the repository into. Then run the command:
```
git clone https://github.com/NomanTrips/fhirbridge.git
```
- If you don't have git on your computer or if your on windows you will need to get git: https://git-scm.com/download/win
- Install dependencies:
```
Jruby -- download from http://jruby.org/
Bundler -- http://bundler.io/
Heroku toolbelt -- https://toolbelt.heroku.com/
```
- Install the api server: In the project folder at the top node where the 'app' folder is run this command:
```
bundle install
```
- Upload to Heroku. First create an account on heroku or login. Then inside the project folder top node enter the following commands:
```
git init
git add .
git commit -m "init"
heroku create
git push heroku master
```
- Now the project code is uploaded to a new app on heroku. We still need to setup the database to get everything working.

### Fhirbase database
- cd to the root directory of the application on your desktop,
- Enter the following command to add a postgres db to the app:
```
heroku addons:add heroku-postgresql --app your-app-name --version=9.4
```
- Go to "https://postgres.heroku.com/databases" and find the database that you just created.
Click on the database and get the db name under the "Resource name". Subsitute this name where it says "YOUR_DB_NAME" below:
```
curl https://raw.githubusercontent.com/fhirbase/fhirbase-build/master/fhirbase.sql \ | pg:psql --app your-app-name YOUR_DB_NAME
```
- You will need to download curl for this step. If your on windows you can do this with Cygwin.
- Run this command setup the database and add the necessary tables:
```
heroku pg:psql --app your-app-name YOUR_DB_NAME --command 'SELECT fhir.generate_tables()'
```
- To check and make sure that everything worked connect to the db and list the tables:
```
heroku pg:psql
\dt
```
- You should see a long list of tables, one for each resource type: condition, allergy, person etc.
 
## Usage
Try out the server functionality using the postman google chrome extension which allows you to send HTTP GET and POST requests.
- Example create patient:
```
HTTP POST https://fhirbridge.net/Patient
headers:
Accept:application/json
body:
	{
	  "resourceType": "Patient",
	  "name": [
	    {
	      "given": [
	        "Gaetano"
	      ],
	      "family": [
	        "Hansen"
	      ]
	    }
	  ]
	}
```
- Example Read:
```
HTTP GET https://fhirbridge.net/Patient/2d6ebe1f-6810-4b50-8b85-085d4ac6c0b2
headers:
Accept:application/json
```

- For more information on making calls to a fhir server see the fhir spec: https://www.hl7.org/fhir/
 
## Security
The api server can be protected using OAuth2 to authorize clients and standard HTTPS with SSL for the communication over the web.
To do this a separate authorization server Mitre connect will be used. I'm still working on this piece.
## Roadmap
- Complete oauth2 integration
- Upgrade to use fhirbase v2
- Basic fhir client which will interact with the server

## Contributing
If you find any bugs or have questions please submit them to the issues on this github project.
## History
TODO: Write history
## Credits
TODO: Write credits
## License
Open source under the MIT license.