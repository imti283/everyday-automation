import ADO_Connection
import ADO_getprojectdetails
import pprint

connection = ADO_Connection.get_ado_connection()
print(connection)
build_client = connection.clients_v6_0.get_build_client()
project_list = ADO_getprojectdetails.get_project_array(connection)
for proj in project_list:
    build_details_failed = build_client.get_builds(proj, result_filter='failed')
    if build_details_failed is not None and len(build_details_failed)>0:
        print(proj," ", build_details_failed[0].requested_for.unique_name, " ", build_details_failed[0].trigger_info)
