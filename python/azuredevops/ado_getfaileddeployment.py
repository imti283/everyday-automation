import ado_connection
import ado_getprojectdetails
import pprint
import datetime

now = datetime.datetime.now()
connection = ado_connection.get_ado_connection()
deploy_client = connection.clients_v6_0.get_release_client()
project_arr = ado_getprojectdetails.get_project_array(connection)
for proj in project_arr:
    deploy_details_failed = deploy_client.get_deployments(proj, deployment_status='failed')
    if deploy_details_failed is not None and len(deploy_details_failed)>0 and (now.date() - deploy_details_failed[0].completed_on.date()).days>30:
        print(proj,'==>>', deploy_details_failed[0].release.name,'==>>', deploy_details_failed[0].release_environment.name,'==>>', deploy_details_failed[0].release_definition.name,'==>>', deploy_details_failed[0].completed_on)
        