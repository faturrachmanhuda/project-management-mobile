from rest_framework.views import exception_handler
from rest_framework.response import Response


def custom_exception_handler(exc, context):
    """Custom exception handler untuk format response yang konsisten"""
    response = exception_handler(exc, context)

    if response is not None:
        custom_response = {
            'error': True,
            'message': '',
            'details': {}
        }

        if isinstance(response.data, dict):
            if 'detail' in response.data:
                custom_response['message'] = response.data['detail']
            else:
                custom_response['details'] = response.data
                custom_response['message'] = 'Validation error'
        else:
            custom_response['message'] = str(response.data)

        response.data = custom_response

    return response
