#!/usr/bin/env groovy
@Library(['piper-lib', 'piper-lib-os']) _

def checkacc() {
	
	withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.JenkinCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){	  
				  sh '''
				  echo "************ Check if Subaccount exists *********************************"
				  echo "************************************************************************** " 
					   pip3 install -r requirements.txt
					   cd scripts
					   python3 installations.py
					   python3 subaccount_exists.py  
				 '''
				is_account_exists = readFile(file: 'myfile.txt')
				print(is_account_exists)	
				return is_account_exists
	}
	
}

node ('CAT_10.237.114.208_Subordinate_1') 
{
withKubeConfig([credentialsId: 'kubeconfigkymabase']) 
{
             
                        sh '''
                          kubectl version
						  sleep 1m
						  '''
dockerExecuteOnKubernetes(script: this, dockerEnvVars: ['pusername':pusername, 'puserpwd':puserpwd], dockerImage: 'docker.wdf.sap.corp:51010/sfext:v3-py' )
{
	try {

		stage ('Git-clone') 
			{
				cleanWs()
          
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'GithubTools',usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){
				sh'''
				git clone https://github.com/VanitaDhanagar/kyma-multitenant-extension.git --branch 'main'
				mv ./ReusableActions/* ./
				git clone https://github.tools.sap/btp-ppu-test/ReusableActions.git --branch 'master'
				mv ./ReusableActions/* ./
                git clone https://github.com/SAP-samples/btp-kyma-multitenant-extension.git --branch 'main'
				mv ./btp-kyma-multitenant-extension/* ./
				'''
				

				}

			}
			stage ('Subaccount_SetUp') 
			{
				
				
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.JenkinCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){
           
				    writeJSON file: 'manifest.json', json: params.ManifestJsonFileContent
							data1 = readJSON file:'manifest.json'
							print(data1) 
				    sh '''
				    mv manifest.json ./config/
				    '''
				    is_account_exists = checkacc()
				    print(is_account_exists)	

				    if (is_account_exists == 'True') {

					print("Subaccount already exists.")
					
				     }

				}
				  
			}
		stage ("create_customer_destination")
		{
         withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.JenkinCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){		
			    data = readJSON file: './config/manifest.json'		  
				orgname = "${data.subaccounts[0].org_name}"
				print orgname
				spacename = "${data.subaccounts[0].space_name}"
		         print spacename
				 
				       
			        
			       sh "cf login -a https://api.cf.us20.hana.ondemand.com -u $USERNAME -p $PASSWORD -o cf-citykyma-93951304-9109-44bc-ac3f-53c3ac8b309b -s hana"
			
			       sh '''
		                pwd
						curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 --output jq
					    chmod +x jq
					    mv jq /usr/local/bin/jq
					    cd automatinscript
						chmod +x ./OnPremiseDestination.sh
						./OnPremiseDestination.sh
                        
						
				    '''	
		 }
		}
		
		stage('UI_Test_Execution')
		{
			withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.JenkinCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){		
				//filepath = "C://Jenkins//workspace//${JOB_NAME}//userlist.xlsx"	  
			    data = readJSON file: './config/manifest.json'		  
				paramSub = "${data.subaccounts[0].display_name}"
				print paramSub
				landscapeUrl = "${data.global_logon.landscape_url}"			
				print landscapeUrl
				orgname = "${data.subaccounts[0].org_name}"
				print orgname
				spacename = "${data.subaccounts[0].space_name}"
				print spacename
				username = env.username
				print username
				password = env.password
				print password
				build job: 'Kyma_Multitenant_UI_Factory', parameters: [[$class: 'StringParameterValue', name: 'URL', value: landscapeUrl],[$class: 'StringParameterValue', name: 'Username', value: username],[$class: 'StringParameterValue', name: 'Password', value: password],[$class: 'StringParameterValue', name: 'Subaccount', value: paramSub]]
			     
		}
		}
		
		
		}
				 
	catch(e){
		echo e.toString()
		echo 'This will run only if failed'
		currentBuild.result = "FAILURE"
	}
	finally {
		emailext body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to: 'vanita.dhanagar@sap.com'
	}
}
} 
}

