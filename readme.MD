Terraform with Jenkins – How to Manage Workflows
 
 
In this post, we will learn how to manage Terraform deployments and workflows using Jenkins. We will also implement a Jenkins pipeline to trigger Terraform deployments and destroy the same. This post also covers some of Jenkins’s most useful customization options to manage the Terraform workflow.
What is Jenkins?
Jenkins is an open-source CI/CD automation tool developed in Java. It is one of the oldest automation tools, which gained popularity in the early days of “mainstream” DevOps. It is used by many organizations and users today, has active community support, and has a roadmap for the future.
Jenkins is not just a CI/CD automation tool but a framework that is capable of implementing various automation use cases. It covers scenarios that range from the automated release of updates to mobile applications to embedded software and hardware systems.
Check out also CircleCi vs. Jenkins comparison.
Jenkins provides a wide range of plugins to support various automation scenarios. Terraform is one of the plugins we will use in this blog post to implement an end-to-end workflow in a step-by-step manner.
Many of the custom tools and features your team would need to build and integrate into a CI/CD pipeline also already exist within the ecosystem of Spacelift, making the whole infrastructure delivery journey a lot easier and smoother. It provides a flexible and robust workflow and a native GitOps experience, so we encourage you to explore how Spacelift makes it easy to work with Terraform.
Step 1: Installing Terraform Plugin on Jenkins
We assume that the basic installation of the Jenkins server is available either locally or on one of the virtual machines. Find the steps to install Jenkins here. The demonstration that follows uses the local installation of Jenkins on macOS.
Once the installation is complete and administrator login is enabled, navigate to the “Manage Jenkins” page by clicking on the tab in the left navigation menu.
 
On the screen that opens up, click on the “Manage Plugins” icon, to install the Terraform plugin.
 
Click on the Installed plugins tab in the left navigation menu, and search for “Terraform” in the search bar.
 
Check the checkbox beside Terraform, and click on “Install without restart.”
Once the installation is successful, it is displayed on the progress screen, as shown below. We can optionally choose to restart Jenkins after this step.
 
Thus we have successfully installed the Terraform plugin in Jenkins.
To confirm the same, navigate to the same path, and see if it is available and enabled in the “Installed plugin” section.
 
Step 2: Installing Terraform Binary
For Jenkins to work with the Terraform plugin, the Terraform binary must be installed. This is done in two ways, depending on whether the Terraform binary is installed separately (when it pre-exists) or if Jenkins auto-installer is used.
Navigate to: the “Dashboard > Manage Jenkins > Global Tool Configuration” page, and scroll to the section which represents “Terraform.”
 
Click on the “Terraform installations…” tab, and the following screen is presented.
 
The form in the center provides us a way to provide this installation a name and specify the location of Terraform installation. In the cases where Terraform was installed before Jenkins, we can specify the path to the Terraform binary in the “Installation directory” field above.
Otherwise, if the Terraform is not installed on the host, we can click “Install automatically.” As mentioned in the help text in the screenshot below, with this option, Jenkins will help us install a specific version from various sources.
 
In the automatic installation, there are several ways to specify the installer. The easiest one is “Install from bintray.com.” If we do not want to take care of maintaining the Terraform installation separately, then this is the easiest way to install Terraform via Jenkins.
The list also provides us with other options where we can control the installation process by specifying where to download the binary from, running custom shell commands to perform the Terraform installation, etc.
In the current example, since I have installed Jenkins locally and already had Terraform installation – simply specifying the path to the “Install directory” was enough. 
There are a couple of buttons named “Add Terraform.” These buttons provide us with additional forms to enable additional Terraform installations. In some cases where different versions of Terraform are used across multiple pipelines, this becomes a handy way to manage Terraform versions. 
Click on “Save,” and we can build our Jenkins pipeline.
Step 3: Preparing the Terraform Config
We will be dealing with a simple Terraform configuration that creates a single EC2 instance in AWS. The config is hosted on Github.
The Jenkins pipeline we develop in the next steps will also consume this configuration from the same location.
 
Step 4: Create a Jenkins Pipeline
Navigate to: “Dashboard” and click on “New Item”.
 
In the following screen, provide a valid name to the pipeline and select the “Pipeline” icon amongst all the options. Click on “Ok” to save this pipeline.
 
Once saved, we are navigated to the Configuration page of the pipeline, where we are provided with multiple options to configure this newly created pipeline. 
Note: If you are new to Jenkins, please take some time to go through the info messages hidden behind the question mark symbol for better understanding.
 
In the general section of this page, several checkboxes are provided for configuration. To begin with, we will configure the essential details for now.
Since our Terraform configuration resides on GitHub, select the “GitHub project” checkbox. This will ask for the project URL; provide the same.
 
For now, skip all other sections and details on this page, and click on Save.
💡 You might also like:
•	How to Automate Terraform Deployments and Infrastructure Provisioning
•	Why DevOps Engineers Recommend Spacelift
•	How to Improve Your Infrastructure as Code using Terraform
Step 5: Jenkins Pipeline Script
Jenkins pipelines are defined using Groovy scripting language. If you are unfamiliar with it, we can take the help of the “Pipeline Syntax” utility provided by Jenkins to generate this script. Navigate to: “Dashboard > TFJenkinsDemo > Configuration.” Scroll to the “Pipeline” section.
Note: “TFJenkinsDemo” is the name of the project I have given to this pipeline. It might be different for readers depending on the name they chose in the previous step.
 
The script field is blank initially. We have added a generic syntax to define various stages of the pipeline with appropriate names and steps. To summarize the same:
1.	We ask the Jenkins pipeline to use “any” available agent to run the following jobs in stages.
2.	There are three stages, and each stage contains steps to – 
o	Checkout: checkout the Terraform config from the Github repo to the agent.
o	Terraform init: initialize the Terraform config by downloading the appropriate providers required by the configuration.
o	Terraform apply: apply the configuration and create resources.
This is just an outline of the current script; the steps are not yet defined. This is where we can use the link to “Pipeline Syntax” provided just above the “Save” button. Click and open the link in a new tab.
To generate the script required by the “Checkout” stage, we can select an appropriate sample step from the dropdown – in this case: git. Fill in the details in the form provided and click on “Generate Pipeline Script.” If this is the first time and the credentials are not configured, we can quickly do so.
 
Copy the generated script and paste it into the “steps” block of the “Checkout” stage.
Similarly, to create steps for the next two stages, follow the same process by selecting appropriate values in the dropdown, as shown in the screenshot below.
 
The final script should look like the one below. The steps defined within individual stages should be self-explanatory.
Note that we have provided the --auto-approve flag in the “Terraform apply” stage to ensure the pipeline does not wait or crash because of the required manual confirmation.
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: '<CREDS>', url: 'https://github.com/sumeetninawe/tf-tuts'
            }
        }
        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform apply') {
            steps {
                sh 'terraform apply --auto-approve'
            }
        }
        
    }
}
Click on Save.
Step 6: Configuring Access to AWS
Till now, we have configured the Terraform plugin on the Jenkins server, installed Terraform, and created a basic pipeline to execute the Terraform code. We have not yet tested the pipeline. Before we test the pipeline, a critical piece is missing – authentication between Jenkins/Terraform and AWS.
Let us explore the options which we have.
1.	If Jenkins is hosted on an EC2 instance within AWS, then an IAM role assignment can be done. The IAM role thus assigned to the EC2 instance enables the Jenkins pipeline to perform appropriate actions on the AWS resources.
2.	If Jenkins is not hosted on AWS, there are multiple ways to address this. The first way is to manually install AWS CLI and configure it with the IAM user’s access key and secret access key on the host machine. When Terraform AWS configurations are applied, these default credentials are automatically picked up by Terraform.
3.	Various plugins are available to manage AWS Keys using Jenkins Credential Manager API, where it is possible to define access scopes. Examples:
o	AWS Secrets Manager Credentials Provider
o	CloudBees AWS Credentials
4.	Plugins are also available to manage credentials for other major cloud provider platforms, examples:
o	Kubernetes
o	Azure
o	GCP
We have followed the second approach for this example since we are dealing with a locally hosted Jenkins server. However, there are multiple ways and plugins to manage credentials in Jenkins.
Please note that depending on the plugin being used, the steps required in the pipeline’s Groovy script will differ. The correct usage should be referred to from the corresponding documentation.
Step 7: Testing the Pipeline
Navigate to: “Dashboard > TFJenkinsDemo.”
From the left navigation menu, click on “Build Now.” In the main panel on the screen, various stages of the pipelines will appear below “Stage View” as they are executed.
 
Once the build is completed, we can see the summary below. It shows details like the date and time of this particular run, how much time each stage took to be executed successfully, etc.
Take a moment to go through all the details here.
 
To know more about the build, click on the sequence number of that particular run in Build History. This provides us with a screen with various tabs on the left.
 
Click on the “Console Output” tab to view the complete log generated. If the build does not succeed, we can investigate the root cause, identify the solution, and decide to take action on changing the pipeline configuration.
 
Since the build indicates success, it means Jenkins has successfully executed the Terraform configuration to create the infrastructure in AWS.
Verify if the EC2 instance / intended infrastructure configured in IaC is created in AWS Console.
 
Step 8: Destroy the Infrastructure Using Jenkins
Our build pipeline is quite straightforward – it applies the given Terraform configuration. However, in the current configuration, it is not possible to destroy the same.
To implement this function, we take the help of build parameters features in Jenkins. Build parameters are a way to accept user input before triggering any pipeline. This input is incorporated in the pipeline where it is required.
Our intention with build parameters is to provide an option to the users to select which “Action” they wish to perform – apply or destroy. Depending on the selection, the pipeline will either run the “apply” command or “destroy” the infrastructure.
Navigate to: “Dashboard > TFJenkinsDemo > Configuration.” In the general section, click on the checkbox stating, “This project is parameterized.” Take a moment to read through the information text.
 
Select the “Choice Parameter” and fill in the form as shown below. The name represents the “variable” name we will use in our pipeline script to replace the variable with the selected value.
Each choice is listed on the next line; here, we have two choices – apply and destroy. These are potential values.
 
Scroll down to the Pipeline definition script, and use the action variable in the “Terraform apply” stage. Note that we have changed the name of this stage as well.
…
stage('Terraform action') {
            steps {
                sh 'terraform ${action} --auto-approve'
            }
        }
…
Click on Save. Let us retrigger the pipeline to destroy the resources created in our previous run.
This time we can select the action that should be performed on the given Terraform configuration. Select “destroy” and click on Build.
 
As seen in the screenshot below, the pipeline was successfully completed.
 
To verify the same, navigate to the AWS console and make sure the resources created using the Terraform config are deleted.
 
Step 9: Automatic Triggering
It is often desired that the pipelines be triggered automatically based on an event.
For example, when a commit is made on a specific branch or a PR is merged to a specific branch – the pipeline we developed above should be triggered automatically. So that the changes introduced in the new commits are automatically applied.
There are two ways to achieve this:
1.	By triggering the events to Jenkins via a webhook
2.	Jenkins to poll the source code at regular intervals to detect changes
Apart from this, Jenkins provides many options to trigger the builds based on various conditions, as shown in the screenshot below.
 
As mentioned earlier, since this is a local installation of the Jenkins server, it would be impossible to configure a GitHub webhook. This could also be the case if Jenkins is placed behind a firewall and incoming webhook traffic is not allowed. In that case, we configure the polling SCM option.
Since we have already configured the connection to our GitHub repository while making it available for the pipeline, configuring the “Poll SCM” option is easy. We need to provide a schedule value in the cron job notation. Here we are asking the pipeline to poll the SCM every 2 minutes.
 
Click on Save. To see this trigger in action, commit a new change to the Terraform configuration repository. For this demo, I have just edited the README.md file.
 
When the “Poll SCM” trigger is configured, a new tab appears on the Pipeline’s home page named “Git Polling Log.”
This provides the logs of all the triggers detected by this polling mechanism which caused the pipeline to run.
 
Read more about how to manage GitHub with Terraform.
Key Points
Jenkins is a great tool for implementing pipeline automation. It covers a wide range of use cases. It is possible to customize the Terraform workflow pipelines in many different ways truly. For organizations that have adopted Jenkins for a wide range of tasks and for whom Terraform adoption is still in the nascent phase – implementing Terraform pipelines would make more sense.
However, a generalized capability thus provided may not always provide a straight path for specific requirements. As seen in this demonstration, various aspects listed below are managed in different places and may depend on more plugins.
1.	Credentials management depends on plugin.
2.	Terraform plugins to manage installation and execution environment.
3.	State management is inherently owned by Jenkins – there are advantages and disadvantages to this approach.
4.	Pipelines may not offer much flexibility.
5.	The learning curve involved in Groovy Script, as against YAML, which is the standard today.
6.	Advanced analysis like drift detection, policy as code, costing, etc., are not available.
Managing infrastructure using Terraform IaC has many facets associated with it. Terraform configuration files are the beginning of it. However, the next steps need a specialized approach. Spacelift offers various features covering end-to-end infrastructure management activities using Terraform and other configuration languages.
As we have seen in the list above, managing infrastructure is complicated. With a focused approach and advanced features, Spacelift makes it easy to manage infrastructure on any platform using multiple IaC technologies.
1.	Workflow automation for end-to-end provisioning
2.	Drift detection
3.	Policy-as-code support
4.	Team collaboration
5.	Cost forecast
6.	Impact analysis
7.	Visualization tools
8.	Extensive provider and module resources
Note: New versions of Terraform will be placed under the BUSL license, but everything created before version 1.5.x stays open-source. OpenTofu is an open-source version of Terraform that will expand on Terraform’s existing concepts and offerings. It is a viable alternative to HashiCorp’s Terraform, being forked from Terraform version 1.5.6. OpenTofu retained all the features and functionalities that had made Terraform popular among developers while also introducing improvements and enhancements. OpenTofu works with your existing Terraform state file, so you won’t have any issues when you are migrating to it.

