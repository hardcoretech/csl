Consolidated Screening List (CSL)
=================================

The Consolidated Screening List (CSL) is a list of parties for which the United States Government maintains
 restrictions on certain exports, reexports or transfers of items. This project creates a searchable API endpoint
  around those restrictions as well as automated jobs to keep the data current. 
  See [this site](https://www.export.gov/article?id=Consolidated-Screening-List) for more information about the CSL.

# Installation

### Ruby

This repository has been tested against [Ruby 2.6](http://www.ruby-lang.org/en/downloads/).

### Gems

Install bundler and other required gems:

    gem install bundler
    bundle install
    
The `charlock_holmes` gem requires the UCI libraries to be installed. If you are using Homebrew, it's probably as simple as this:
     
     brew install icu4c

More information about the gem can be found [here](https://github.com/brianmario/charlock_holmes)             

### ElasticSearch

CSL uses [Elasticsearch](http://www.elasticsearch.org/) ~= 7.1 for fulltext search. On a Mac, it's easy to
 install with [Homebrew](http://mxcl.github.com/homebrew/).

    brew install elasticsearch

Otherwise, follow the [instructions](http://www.elasticsearch.org/download/) to download and run it.

You can also run it via Docker:

    docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.1.1


### Running CSL locally

Create the indexes:

    bundle exec rake db:create
    
Fire up a web server to host the JSON API:

    bundle exec rails s
    
Import data for a few sources:

    bundle exec rake ita:import[ScreeningList::DplData]
    bundle exec rake ita:import[ScreeningList::DtcData]
    bundle exec rake ita:import[ScreeningList::SdnData]
    
See `app/importers/screening_list/*_data.rb` for a complete list.

Run some searches:

    curl -s "http://localhost:3000/consolidated_screening_list/search?sources=SDN,DPL&q=smith"


### Test Suite

Make sure Elasticsearch 7 is running locally on port 9200 before running the test suite: 

    rake spec

### Code Coverage

After running your tests, view the code coverage report by opening `coverage/index.html`.

### Architecture and Deployment Instructions

CSL is essentially a Rails application and a set of recurring jobs that interact with an Elasticsearch cluster. There
 are many ways to orchestrate such a setup, including Elastic Beanstalk, OpsWorks/Chef, CloudFormation, Kubernetes
 , Capistrano, and of course just
  installing and configuring resources manually. The recurring import jobs in this project are based 
  on [ActiveJob](https://edgeguides.rubyonrails.org/active_job_basics.html), which allows for different queueing backends. 
  However, in this section we will focus on deploying to Elastic Beanstalk.

#### Why Beanstalk
  
Deploying via Beanstalk offers several benefits out of the box:

* Capacity: Specify different instance types for both Worker tier and Web Server tier, and let Beanstalk automatically
 scale up/down based on time of day or some metric like CPU load. Beanstalk handles spreading workers across multiple
 availability zones.
* Availability: Beanstalk monitors the health of the containers running the Web tier and Worker tier and
 automatically reprovisions them in case of failure. 
* Visibilty: Beanstalk provides a URL to access the Web Tier or you can provide your own custom domain.  
* Crons: Asynchronous/recurring jobs are specified via using traditional cron syntax in a `cron.yaml` file that is
 part of the code repository versus some separate orchestration configuration. Unlike single-machine cron, the Worker
  tier is auto-scalable to accommodate any workload volume.
* Managed container updates: Beanstalk can automatically upgrade the underlying OS for the containers so security
 patches are always in place.
* Deployments: Beanstalk supports a variety of deployment orchestrations, from all at once to rolling deployments
 with health checks.

#### Architecture
  
With Elastic Beanstalk, we have three components in a CSL deployment: the Web Server tier, the Worker tier, and a
 standard SQS queue:
 
![Rails app in Beanstalk](https://raw.githubusercontent.com/tawan/active-elastic-job/master/docs/architecture.png)
  

* The Web Server tier hosts the JSON API for CSL search requests.
* The Worker tier dequeues import jobs from the SQS queue and processes the tasks.
* The SQS queue provides the queueing backend to asynchronously process the various import jobs for different
 screening lists as well as to upload CSV/TSV versions of the entire data set to an S3 bucket. Beanstalk
  automatically handles polling the queue for a task, dispatching it to a worker, and deleting the task from the
   queue on successful completion of the work. The workflow is as follows: 
   
![Beanstalk SQS worker interaction](https://3.bp.blogspot.com/-SKsLwkbwetM/WCvMPSk4vAI/AAAAAAACiPk/XtcGAJgtUvAqZzgOED0MhFAQuF69lNUnACLcB/s1600/SQSD.gif)
 
Outside of Elastic Beanstalk, CSL interacts with an Elasticsearch 7 cluster and AWS S3. Just as there are many ways
 to deploy a web app, there are also many ways to run an Elasticsearch cluster, including hosted AWS 
 Elasticsearch, hosted Elasticsearch from Elastic, orchestrated via OpsWorks/Chef, CloudFormation, Kubernetes, and
  manually provisioning a cluster.

#### Deployment

Even inside of Elastic Beanstalk, there are a number of ways to set up a Rails application and configure a deployment
. Please refer to the [documentation](https://docs.aws.amazon.com/en_pv/elasticbeanstalk/latest/dg/GettingStarted.html) to see which way is best for you. 

* Elasticsearch: Once you have your Elasticsearch 7 cluster provisioned, make a note of the cluster URL, usually
 available on port 9200.
* Specify the following environment variables in both your Web tier and Worker tier configurations under Software: 
    * `AWS_ACCESS_KEY_ID`, `AWS_REGION`, and `AWS_SECRET_ACCESS_KEY`: For accessing the S3 bucket where the CSV/TSV
     exports will be uploaded.
    * `ELASTICSEARCH_URL`: The access point for your Elasticsearch 7 cluster.
* In the Worker tier, modify the worker configuration to handle just 1 HTTP connection at a time. You can increase this
 but you will need a larger instance type.
* In the Worker tier, specify a SQS queue that you've created or just let Beanstalk create one for you.

Once you have deployed CSL to Beanstalk (via Zip file, S3, etc), the various indices will automatically be created in
 Elasticsearch. The screening list imports and the CSV/TSV exports will begin based on the schedule defined in the
  `cron.yaml` file.  

### Provenance

The CSL code was originally part of [this repository](https://github.com/GovWizely/webservices), which was decomposed into multiple repositories and deprecated.