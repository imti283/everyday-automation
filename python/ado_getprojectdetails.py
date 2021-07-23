import ado_connection
import pprint


def get_project_array(connection):
    if not connection:
        connection = ado_connection.get_ado_connection()
    else:
        print("connection not found")
    core_client = connection.clients.get_core_client()
    # Get the first page of projects
    get_projects_response = core_client.get_projects()
    index = 0
    project_arr = []
    while get_projects_response is not None:
        for project in get_projects_response.value:
            pprint.pprint("Project No - [" + str(index) + "] Is - " + project.name)
            project_arr.append(project.name)
            #Project_Definition_Url = "https://vsrm.dev.azure.com/myOrg/{project}/_apis/release/definitions/{definitionId}?api-version=6.1-preview.4"
            index += 1
        if get_projects_response.continuation_token is not None and get_projects_response.continuation_token != "":
            # Get the next page of projects
            get_projects_response = core_client.get_projects(continuation_token=get_projects_response.continuation_token)
        else:
            # All projects have been retrieved
            get_projects_response = None
    return project_arr