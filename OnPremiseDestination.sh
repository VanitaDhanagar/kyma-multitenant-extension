echo "********************Create destination service Instance ***********************"
                                             
                                             
                                                            cf cs destination lite EasyFranchise-S4HANA 
                                                            sleep 20
                                                            c=0
                                                            while [ "$c" -le 20 ];
                                                            do
                                                                           cf s > ab.txt
                                                                           DestInstCreation=`cat ab.txt | grep 'EasyFranchise-S4HANA' | grep -w 'create succeeded'| wc -l`
                                                                           if [ "$DestInstCreation" -gt 0 ]
                                                                           then       
                                                                           echo " Validation Passed :EasyFranchise-S4HANA creation succesful ."
                                                                           break
                                                                           else
                                                                           echo "EasyFranchise-S4HANA creation is still in progress......"
                                                                           sleep 25
                                                                           c=$(( c + 1))
                                                                           fi
                                                              done
                                             
 echo "**************Generate service keys for created destination service **************"
                              
                                                            cf create-service-key EasyFranchise-S4HANA my-destInstKyma-key 
                                                                           c=0
                                                                 while [ "$c" -le 20 ];
                                                                           do
                                                               cf service-key EasyFranchise-S4HANA my-destInstKyma-key > ab.txt
                                                               DestbindCreation=`cat ab.txt | grep -w 'clientid'| wc -l`
                                                                           if [ "$DestbindCreation" -gt 0 ]
                                                                           then       
                                                                           echo " Validation Passed :my-destInstKyma-key  binding creation succesful ."
                                                                           break
                                                                           else
                                                                           echo "my-destInstKyma-key  bindings creation is still in progress......"
                                                                           sleep 25
                                                                           c=$(( c + 1))
                                                                           fi
                                                            done
                                                            sleep 20
                                                            
echo "******** Get Client id ,Client Secret,Authentication url ,Destination uri from above generated service keys *************"
                                                            ClientId=`cat ab.txt | sed -n '2,$ p' | jq -r '.clientid'`
                                                            ClientSecret=`cat ab.txt | sed -n '2,$ p' | jq -r '.clientsecret'`
                                                            AuthenticationUrl=`cat ab.txt | sed -n '2,$ p' | jq -r '.url'`
                                                            DestinationUri=`cat ab.txt | sed -n '2,$ p' | jq -r '.uri'`
                                             
                                             
echo "***************Fetch access token by sending clientid & clientsecret***********"
                                                                                          
         access_token=`curl -s POST -u $ClientId:$ClientSecret -d grant_type=client_credentials $AuthenticationUrl/oauth/token -o json | jq '.access_token' | sed 's/"//g'`
         
echo "********************Create Destination API named EasyFranchise-S4HANA **************************************"

           
	     
             
             
			 
			echo "Application url in destination is configured as :   https://my304263.s4hana.ondemand.com "
			
			curl --location --request POST $DestinationUri/destination-configuration/v1/subaccountDestinations --header "Authorization: bearer $access_token" --header 'Content-Type: application/json' --data-raw '{"Name": "EasyFranchise-S4HANA","Type": "HTTP","URL": "'https://my304263.s4hana.ondemand.com'","ProxyType": "OnPremise","Authentication": "BasicAuthentication","User": "'INBOUND_COMM_USER_BTP_EXTENSIONMAY'","Password": "'ZGVgBuPiBnQblqCKND$xaxBnhMBMhwmg9iESZxRL'" }'
	