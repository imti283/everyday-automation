from azure.devops.connection import Connection
from msrest.authentication import BasicAuthentication
import pprint

# Fill in with your personal access token and org URL
def get_ado_connection():
    # Fill in with your personal access token and org URL
    personal_access_token = '<dummyPAT>'
    organization_url = 'https://dev.azure.com/myOrg'
    # Create a connection to the org
    credentials = BasicAuthentication('', personal_access_token)
    connection = Connection(base_url=organization_url, creds=credentials)
    return connection
            
