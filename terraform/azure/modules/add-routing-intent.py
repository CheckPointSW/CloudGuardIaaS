import json
import requests
import sys


def perform_put_request(url, data, headers=None):
    """
    This function perform the PUT request to Azure in order to edit the vWAN Hub Routing-Intent
    """
    result = {"status": "success", "message": ""}
    try:
        response = requests.put(url, json=data, headers=headers)
        result["message"] = response.text
    except Exception as e:
        result["status"] = "error"
        result["message"] = f"An error occurred: {str(e)}"
    return result


if __name__ == "__main__":
    """
    This script receives url, body, and authorization token as arguments and set vWAN Hub Routing-Intent
    """
    api_url = sys.argv[1]
    api_data = eval(sys.argv[2])
    auth_token = sys.argv[3]
    api_headers = {"Authorization": f'Bearer {auth_token}'}
    result = perform_put_request(api_url, api_data, api_headers)
    print(json.dumps(result))
