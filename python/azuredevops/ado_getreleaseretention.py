import ado_connection
import ado_getprojectdetails
import pprint

connection = ado_connection.get_ado_connection()
print(connection)
release_client = connection.clients.get_release_client()
project_arr = ado_getprojectdetails.get_project_array(connection)
for proj_arr in project_arr:
    release_defs = release_client.get_release_definitions(project=proj_arr)
    for rel_def in release_defs.value:
        release_details = release_client.get_release_definition(project=proj_arr,definition_id=rel_def.id)
        for rel_det in release_details.environments:
            print(rel_det.retention_policy.serialize()," ", rel_det.name, " ", rel_def.name, " ", proj_arr)
            rel_det.retention_policy.days_to_keep = 45
            rel_det.retention_policy.releases_to_keep = 3
            rel_det.retention_policy.retain_build = True
            release_details_update = release_client.update_release_definition(release_definition=release_details,project=release_details.name)